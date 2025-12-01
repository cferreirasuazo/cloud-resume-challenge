import os
import json
import boto3

dynamodb = boto3.client("dynamodb")
TABLE = os.environ.get("COUNTER_TABLE", "VisitsTable")  # set as env var in Lambda

def handler(event, context):
    # increment the single counter item and return the new value
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
            "headers": {"Content-Type": "application/json"},
            "body": json.dumps({"count": new_count})
        }
    except Exception as e:
        return {
            "statusCode": 500,
            "body": json.dumps({"error": str(e)})
        }
