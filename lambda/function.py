import json
import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)

VALID_API_KEYS = ["yuXCNy8Mnk8HnDCOvsypj3C4Q5z2yL0P93R8YIXt"]

def generate_policy(principal_id, effect, resource):
    return {
        "principalId": principal_id,
        "policyDocument": {
            "Version": "2012-10-17",
            "Statement": [
                {
                    "Action": "execute-api:Invoke",
                    "Effect": effect,
                    "Resource": resource
                }
            ]
        },
        "context": {
            "message": "Authorization successful" if effect == "Allow" else "Invalid API Key"
        }
    }

def lambda_handler(event, context):
    logger.info("Received event: %s", json.dumps(event, indent=2))

    headers = event.get("headers", {})
    api_key = headers.get("x-api-key", "")

    logger.info("API Key received: %s", api_key)

    if api_key in VALID_API_KEYS:
        logger.info("Authorization successful")
        return generate_policy("user", "Allow", event["methodArn"])
    else:
        logger.warning("Authorization failed: Invalid API Key")
        return generate_policy("user", "Deny", event["methodArn"])
