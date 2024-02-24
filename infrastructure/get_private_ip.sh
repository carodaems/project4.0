#!/bin/bash

# Use the outputs from Terraform
CLUSTER_NAME="$1"
SERVICE_NAME="$2"
# Delay in seconds between each attempt
DELAY=5

while true; do
    # Get the task ARN using the AWS CLI
    TASK_ARN=$(aws ecs list-tasks --cluster "$CLUSTER_NAME" --service-name "$SERVICE_NAME" --desired-status RUNNING --query 'taskArns[0]' --output text)

    # Check if TASK_ARN is not empty
    if [ "$TASK_ARN" != "None" ]; then
        # Describe the task to check if it's running
        TASK_DESCRIPTION=$(aws ecs describe-tasks --cluster "$CLUSTER_NAME" --tasks "$TASK_ARN" --query 'tasks[0]')
        TASK_STATUS=$(echo $TASK_DESCRIPTION | jq -r '.lastStatus')

        # Check if the task is running
        if [ "$TASK_STATUS" == "RUNNING" ]; then
            # Extract the Private IP address
            PRIVATE_IP=$(echo $TASK_DESCRIPTION | jq -r '.attachments[0].details[] | select(.name=="privateIPv4Address") | .value')

            # Check if PRIVATE_IP is not empty
            if [ -n "$PRIVATE_IP" ]; then
                echo "{\"private_ip\": \"http://$PRIVATE_IP:5000\"}"
                break
            fi
        fi
    fi
    sleep $DELAY
done
