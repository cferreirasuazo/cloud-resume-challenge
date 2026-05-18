import os
import json
import boto3

dynamodb = boto3.client("dynamodb")
TABLE = os.environ.get("COUNTER_TABLE", "VisitsTable")

CORS_HEADERS = {
    "Content-Type": "application/json",
    "Access-Control-Allow-Origin": "*",
}

def handler(event, context):
    try:
        resp = dynamodb.update_item(
            TableName=TABLE,
            Key={"id": {"S": "visits"}},
            UpdateExpression="SET #c = if_not_exists(#c, :zero) + :inc",
            ExpressionAttributeNames={"#c": "count"},
            ExpressionAttributeValues={":inc": {"N": "1"}, ":zero": {"N": "0"}},
            ReturnValues="UPDATED_NEW"
        )
        new_count = int(resp["Attributes"]["count"]["N"])
        return {
            "statusCode": 200,
            "headers": CORS_HEADERS,
            "body": json.dumps({"count": new_count}),
        }
    except Exception as e:
        return {
            "statusCode": 500,
            "headers": CORS_HEADERS,
            "body": json.dumps({"error": str(e)}),
        }
