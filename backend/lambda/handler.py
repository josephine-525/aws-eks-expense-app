import base64
import json
import os
import re
import uuid
from datetime import datetime, timezone
from decimal import Decimal

import boto3

_table = None


def _get_table():
    global _table
    if _table is not None:
        return _table
    endpoint = (os.environ.get("DYNAMODB_ENDPOINT") or os.environ.get("AWS_ENDPOINT_URL") or "").strip()
    kwargs = {}
    if endpoint:
        kwargs["endpoint_url"] = endpoint
    region = (os.environ.get("AWS_DEFAULT_REGION") or os.environ.get("AWS_REGION") or "").strip()
    if region:
        kwargs["region_name"] = region
    _table = boto3.resource("dynamodb", **kwargs).Table(os.environ["TABLE_NAME"])
    return _table
_MONTH_RE = re.compile(r"^\d{4}-\d{2}$")
_E_EXPENSE_MONTH = re.compile(r"^E#(\d{4}-\d{2})#")


def _headers():
    return {
        "Content-Type": "application/json",
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Headers": "content-type",
        "Access-Control-Allow-Methods": "GET,POST,OPTIONS",
    }


def _path(event):
    rc = event.get("requestContext") or {}
    http = rc.get("http") or {}
    return (http.get("path") or event.get("rawPath") or "").rstrip("/") or "/"


def _json(obj):
    def _conv(o):
        if isinstance(o, Decimal):
            return float(o)
        raise TypeError

    return json.dumps(obj, default=_conv)


def _float(x, default=0.0):
    try:
        if x is None:
            return default
        return float(x)
    except (TypeError, ValueError):
        return default


def _dyn_num(x):
    """DynamoDB N 类型需要 Decimal，不能直接用 float。"""
    return Decimal(str(_float(x)))


def _month_meta_id(month_key):
    return f"M#{month_key}"


def _expense_prefix(month_key):
    return f"E#{month_key}#"


def _parse_json_body(event):
    raw = event.get("body") or "{}"
    if event.get("isBase64Encoded"):
        raw = base64.b64decode(raw).decode("utf-8")
    return json.loads(raw)


def handler(event, context):
    headers = _headers()
    method = (event.get("requestContext") or {}).get("http", {}).get("method", "")
    if method == "OPTIONS":
        return {"statusCode": 204, "headers": headers, "body": ""}

    path = _path(event)
    qs = event.get("queryStringParameters") or {}

    try:
        if method == "GET" and path == "/expenses":
            return _get_expenses(qs, headers)
        if method == "POST" and path == "/expenses":
            return _post_expense(event, headers)
        if method == "GET" and path == "/months":
            return _get_months(qs, headers)
        if method == "POST" and path == "/months":
            return _post_month(event, headers)
        if method == "GET" and path == "/summary":
            return _get_summary(qs, headers)

        return {
            "statusCode": 404,
            "headers": headers,
            "body": _json({"error": "not_found", "path": path}),
        }
    except Exception as e:
        return {
            "statusCode": 500,
            "headers": headers,
            "body": _json({"error": str(e)}),
        }


def _get_expenses(qs, headers):
    uid = qs.get("user_id", "demo")
    month_key = qs.get("month", "")
    if not _MONTH_RE.match(month_key):
        return {
            "statusCode": 400,
            "headers": headers,
            "body": _json({"error": "invalid_month", "hint": "YYYY-MM"}),
        }
    prefix = _expense_prefix(month_key)
    resp = _get_table().query(
        KeyConditionExpression="user_id = :u AND begins_with(expense_id, :p)",
        ExpressionAttributeValues={":u": uid, ":p": prefix},
    )
    items = [i for i in resp.get("Items", []) if str(i.get("expense_id", "")).startswith("E#")]
    return {"statusCode": 200, "headers": headers, "body": _json({"items": items, "month": month_key})}


def _post_expense(event, headers):
    body = _parse_json_body(event)
    uid = str(body.get("user_id") or "demo").strip() or "demo"
    month_key = body.get("month_key") or body.get("month", "")
    if not _MONTH_RE.match(month_key):
        return {
            "statusCode": 400,
            "headers": headers,
            "body": _json({"error": "invalid_month", "hint": "YYYY-MM"}),
        }
    suffix = body.get("expense_id") or f"{int(datetime.now(timezone.utc).timestamp() * 1000)}-{uuid.uuid4().hex[:8]}"
    eid = f"{_expense_prefix(month_key)}{suffix}"
    item = {
        "user_id": uid,
        "expense_id": eid,
        "item_type": "expense",
        "month_key": month_key,
        "amount": _dyn_num(body.get("amount")),
        "category": str(body.get("category", "uncategorized")),
        "note": str(body.get("note", "")),
        "created_at": datetime.now(timezone.utc).isoformat(),
    }
    _get_table().put_item(Item=item)
    out_item = {**item, "amount": _float(item["amount"])}
    return {"statusCode": 200, "headers": headers, "body": _json({"ok": True, "item": out_item})}


def _get_months(qs, headers):
    uid = qs.get("user_id", "demo")
    meta_by_month = {}

    mkwargs = {
        "KeyConditionExpression": "user_id = :u AND begins_with(expense_id, :p)",
        "ExpressionAttributeValues": {":u": uid, ":p": "M#"},
    }
    while True:
        resp = _get_table().query(**mkwargs)
        for i in resp.get("Items", []):
            eid = str(i.get("expense_id", ""))
            if not eid.startswith("M#"):
                continue
            mk = eid[2:]
            if _MONTH_RE.match(mk):
                meta_by_month[mk] = {
                    "month_key": mk,
                    "budget_cap": _float(i.get("budget_cap")),
                    "title": str(i.get("title", "")),
                    "updated_at": str(i.get("updated_at", "")),
                }
        lek = resp.get("LastEvaluatedKey")
        if not lek:
            break
        mkwargs["ExclusiveStartKey"] = lek

    month_keys = set(meta_by_month.keys())

    ekwargs = {
        "KeyConditionExpression": "user_id = :u AND begins_with(expense_id, :p)",
        "ExpressionAttributeValues": {":u": uid, ":p": "E#"},
        "ProjectionExpression": "expense_id",
    }
    while True:
        er = _get_table().query(**ekwargs)
        for i in er.get("Items", []):
            eid = str(i.get("expense_id", ""))
            em = _E_EXPENSE_MONTH.match(eid)
            if em:
                month_keys.add(em.group(1))
        lek = er.get("LastEvaluatedKey")
        if not lek:
            break
        ekwargs["ExclusiveStartKey"] = lek

    months = []
    for mk in sorted(month_keys, reverse=True):
        if mk in meta_by_month:
            months.append(meta_by_month[mk])
        else:
            months.append(
                {
                    "month_key": mk,
                    "budget_cap": 0.0,
                    "title": "",
                    "updated_at": "",
                }
            )
    return {"statusCode": 200, "headers": headers, "body": _json({"months": months})}


def _post_month(event, headers):
    body = _parse_json_body(event)
    uid = str(body.get("user_id") or "demo").strip() or "demo"
    month_key = body.get("month_key") or body.get("month", "")
    if not _MONTH_RE.match(month_key):
        return {
            "statusCode": 400,
            "headers": headers,
            "body": _json({"error": "invalid_month", "hint": "YYYY-MM"}),
        }
    budget_cap = _dyn_num(body.get("budget_cap"))
    title = str(body.get("title", ""))
    now = datetime.now(timezone.utc).isoformat()
    item = {
        "user_id": uid,
        "expense_id": _month_meta_id(month_key),
        "item_type": "month",
        "month_key": month_key,
        "budget_cap": budget_cap,
        "title": title,
        "updated_at": now,
    }
    _get_table().put_item(Item=item)
    out = {**item, "budget_cap": _float(item["budget_cap"])}
    return {"statusCode": 200, "headers": headers, "body": _json({"ok": True, "month": out})}


def _get_summary(qs, headers):
    uid = qs.get("user_id", "demo")
    month_key = qs.get("month", "")
    if not _MONTH_RE.match(month_key):
        return {
            "statusCode": 400,
            "headers": headers,
            "body": _json({"error": "invalid_month", "hint": "YYYY-MM"}),
        }
    meta = _get_table().get_item(
        Key={"user_id": uid, "expense_id": _month_meta_id(month_key)}
    ).get("Item")
    budget_cap = _float((meta or {}).get("budget_cap"))

    prefix = _expense_prefix(month_key)
    resp = _get_table().query(
        KeyConditionExpression="user_id = :u AND begins_with(expense_id, :p)",
        ExpressionAttributeValues={":u": uid, ":p": prefix},
    )
    total = sum(_float(i.get("amount")) for i in resp.get("Items", []))

    notifications = []
    if budget_cap > 0:
        ratio = total / budget_cap
        if ratio >= 1:
            notifications.append(
                {
                    "level": "danger",
                    "code": "over100",
                    "text": f"本月支出已超过预算 100%（{total:.2f} / {budget_cap:.2f}）。",
                }
            )
            notifications.append(
                {
                    "level": "warn",
                    "code": "over90_stacked",
                    "text": f"同时已超过预算 90% 警戒线（{total:.2f} / {budget_cap:.2f}）。",
                }
            )
        elif ratio >= 0.9:
            notifications.append(
                {
                    "level": "warn",
                    "code": "over90",
                    "text": f"本月支出已达预算的 90% 以上（{total:.2f} / {budget_cap:.2f}）。",
                }
            )
    else:
        notifications.append(
            {
                "level": "info",
                "code": "no_budget",
                "text": "尚未设置本月预算，铃铛仅在设置预算后根据支出比例提醒。",
            }
        )

    return {
        "statusCode": 200,
        "headers": headers,
        "body": _json(
            {
                "month_key": month_key,
                "total": total,
                "budget_cap": budget_cap,
                "expense_count": len(resp.get("Items", [])),
                "notifications": notifications,
            }
        ),
    }
