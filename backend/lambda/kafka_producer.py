"""Fire-and-forget Kafka producer for expense events.

No-op unless KAFKA_BOOTSTRAP_SERVERS is set -- local docker-compose and any
runtime without a Kafka cluster nearby just skip this silently, same pattern
as DYNAMODB_ENDPOINT being optional. A publish failure is logged and
swallowed, never raised -- the caller's own write (DynamoDB) already
succeeded by the time this runs, and a producer never needs to know whether
anything downstream is even listening.
"""

import json
import os

_producer = None
_producer_init_attempted = False


def _get_producer():
    global _producer, _producer_init_attempted
    if _producer_init_attempted:
        return _producer
    _producer_init_attempted = True

    bootstrap = (os.environ.get("KAFKA_BOOTSTRAP_SERVERS") or "").strip()
    if not bootstrap:
        return None

    from kafka import KafkaProducer

    try:
        _producer = KafkaProducer(
            bootstrap_servers=bootstrap.split(","),
            value_serializer=lambda v: json.dumps(v).encode("utf-8"),
            key_serializer=lambda k: k.encode("utf-8"),
            max_block_ms=2000,
            request_timeout_ms=3000,
        )
    except Exception as e:
        print(f"[kafka_producer] init failed, staying no-op: {e}")
        _producer = None
    return _producer


def produce_expense_created(out_item: dict) -> None:
    producer = _get_producer()
    if producer is None:
        return

    topic = os.environ.get("KAFKA_EXPENSE_TOPIC", "expense-events")
    event = {
        "event_type": "expense.created",
        "user_id": out_item["user_id"],
        "expense_id": out_item["expense_id"],
        "month_key": out_item["month_key"],
        "amount": out_item["amount"],
        "category": out_item["category"],
        "created_at": out_item["created_at"],
    }
    try:
        producer.send(topic, key=out_item["user_id"], value=event)
        producer.flush(timeout=2)
    except Exception as e:
        print(f"[kafka_producer] failed to publish expense.created: {e}")
