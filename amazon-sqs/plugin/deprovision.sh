#!/bin/bash
# exit when any command fails
set -e

echo "Sandbox id: ${SIGNADOT_SANDBOX_ID}"
echo "Resource name: ${SIGNADOT_RESOURCE_NAME}"

# Delete the queue.
echo "Deleting SQS queue: ${QUEUE_NAME}"
aws sqs delete-queue --queue-url="${QUEUE_URL}"