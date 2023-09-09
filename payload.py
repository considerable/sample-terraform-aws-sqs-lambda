import json


def lambda_handler(event, context):

    print("1) Received event as JSON - \n" + json.dumps(event, indent=2))

    print("2) Received event as KEY:VALUE - ")
    for key, value in event.items():
        print(key, ":", value)

    return {
        'status': 200,
        'message': json.dumps('Hello there!')
    }
