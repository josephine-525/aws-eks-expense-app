"""HTTP wrapper around the Lambda-style handler for local Docker and ECS-style runs."""

from __future__ import annotations

import os
import sys
from pathlib import Path

from botocore.exceptions import ClientError
from flask import Flask, Response, jsonify, request

LAMBDA_DIR = Path(__file__).resolve().parent / "lambda"
sys.path.insert(0, str(LAMBDA_DIR))
import handler as expense_handler  # noqa: E402


def _ensure_local_table() -> None:
    endpoint = (os.environ.get("DYNAMODB_ENDPOINT") or os.environ.get("AWS_ENDPOINT_URL") or "").strip()
    if not endpoint:
        return
    table_name = os.environ["TABLE_NAME"]
    import boto3

    region = (os.environ.get("AWS_REGION") or os.environ.get("AWS_DEFAULT_REGION") or "us-east-1").strip()
    client = boto3.client("dynamodb", endpoint_url=endpoint, region_name=region)
    try:
        client.describe_table(TableName=table_name)
        return
    except ClientError as e:
        if e.response.get("Error", {}).get("Code") != "ResourceNotFoundException":
            raise
    client.create_table(
        TableName=table_name,
        BillingMode="PAY_PER_REQUEST",
        AttributeDefinitions=[
            {"AttributeName": "user_id", "AttributeType": "S"},
            {"AttributeName": "expense_id", "AttributeType": "S"},
        ],
        KeySchema=[
            {"AttributeName": "user_id", "KeyType": "HASH"},
            {"AttributeName": "expense_id", "KeyType": "RANGE"},
        ],
    )
    client.get_waiter("table_exists").wait(TableName=table_name)


_ensure_local_table()

app = Flask(__name__)


def _to_lambda_event() -> dict:
    path = request.path or "/"
    if not path.startswith("/"):
        path = "/" + path
    qs = request.args.to_dict(flat=True)
    body = None
    if request.method in ("POST", "PUT", "PATCH"):
        body = request.get_data(as_text=True)
    return {
        "version": "2.0",
        "rawPath": path,
        "requestContext": {"http": {"method": request.method, "path": path}},
        "queryStringParameters": qs if qs else None,
        "body": body,
        "isBase64Encoded": False,
    }


def _from_lambda_response(resp: dict) -> Response:
    status = int(resp.get("statusCode", 502))
    headers = resp.get("headers") or {}
    body = resp.get("body")
    if body is None:
        body = ""
    return Response(body, status=status, headers=dict(headers))


@app.get("/")
def root():
    return jsonify(
        ok=True,
        service="expense-api",
        note="Open the UI at http://localhost:3000 (Docker frontend). This port is JSON API only.",
        examples={
            "list_expenses": "GET /expenses?user_id=demo&month=2026-04",
            "months": "GET /months?user_id=demo",
            "summary": "GET /summary?user_id=demo&month=2026-04",
        },
    )


@app.route("/expenses", methods=["GET", "POST", "OPTIONS"])
@app.route("/months", methods=["GET", "POST", "OPTIONS"])
@app.route("/summary", methods=["GET", "OPTIONS"])
def dispatch():
    out = expense_handler.handler(_to_lambda_event(), None)
    return _from_lambda_response(out)
