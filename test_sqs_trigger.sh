#!/bin/bash

# Replace with your Lambda function name
FUNCTION_NAME="my_lambda_test"

# Delete the log group (including log streams and log events), suppressing errors if it doesn't exist
aws logs delete-log-group --log-group-name /aws/lambda/$FUNCTION_NAME 2>/dev/null

# Wait until the log group is deleted
while true; do
    STATUS=$(aws logs describe-log-groups --log-group-name-prefix /aws/lambda/$FUNCTION_NAME --query 'logGroups[].storedBytes' --output json)
    
    # Check if the log group has been deleted (status is empty)
    if [ "$STATUS" == "[]" ]; then
        echo "Test log group deletion completed."
        break
    else
        echo "Waiting for test log group deletion to complete..."
        sleep 5  # Adjust the sleep duration as needed
    fi
done

# Now you can proceed with other actions

# Replace with your AWS CLI profile and region
AWS_PROFILE="default"
AWS_REGION="us-west-2"

# Replace with your SQS queue URL
QUEUE_URL="https://sqs.${AWS_REGION}.amazonaws.com/${AWS_ACCOUNT_NUMBER}/my-main-queue"

# Sample SQS message payload
MESSAGE_PAYLOAD="{\"hello-key\": \"hi-sqs-value\"}"

# Send a message to the SQS queue
aws sqs send-message --queue-url "$QUEUE_URL" --message-body "$MESSAGE_PAYLOAD" --profile "$AWS_PROFILE" --region "$AWS_REGION"

# Print the sent message payload
echo "Sent SQS message payload:"
echo "$MESSAGE_PAYLOAD"
