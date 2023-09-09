#!/bin/bash

# Replace with your Lambda function name
FUNCTION_NAME="my_lambda_test"

# Wait until the log group is created
while true; do
    LOG_GROUP_STATUS=$(aws logs describe-log-groups --log-group-name-prefix /aws/lambda/$FUNCTION_NAME --query 'length(logGroups)' --output json)
    
    # Check if the log group is created (status is 1 or more)
    if [ "$LOG_GROUP_STATUS" -gt 0 ]; then
        echo "Log group has been created."
        break
    else
        echo "Waiting for log group to be created..."
        sleep 5  # Adjust the sleep duration as needed
    fi
done

# Get the latest log stream name
LOG_STREAM_NAME=$(aws logs describe-log-streams --log-group-name /aws/lambda/$FUNCTION_NAME | jq -r '.logStreams | sort_by(.creationTime) | .[-1].logStreamName')

# View the log events for the latest log stream
aws logs get-log-events --log-group-name /aws/lambda/$FUNCTION_NAME --log-stream-name "$LOG_STREAM_NAME" | jq '.events[].message' | grep -o "'body'.*"
