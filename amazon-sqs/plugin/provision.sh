#!/bin/bash
# exit when any command fails
set -e

echo "Provisioning a SQS queue"
echo "Sandbox id: ${SIGNADOT_SANDBOX_ID}"
echo "Resource name: ${SIGNADOT_RESOURCE_NAME}"

# Build args list for the 'create-queue' command.
EXTRA_ARGS=()

if [ ! -z "$ATTRIBUTES" ]
then
  echo "Attributes: ${ATTRIBUTES}"
  EXTRA_ARGS+=(--attributes "${ATTRIBUTES}")
fi
if [ ! -z "$TAGS" ]
then
  echo "Tags: ${TAGS}"
  EXTRA_ARGS+=(--tags "${TAGS}")
fi

# Choose a queue name that's unique to this resource in this sandbox.
QUEUE_NAME="signadot-${SIGNADOT_RESOURCE_NAME}-${SIGNADOT_SANDBOX_ID}"
echo "Creating queue: ${QUEUE_NAME}"

# Create the queue. Capture the JSON output.
QUEUE_INFO=$(aws sqs create-queue --queue-name "${QUEUE_NAME}" "${EXTRA_ARGS[@]}")
echo "${QUEUE_INFO}"

# Extract the queue URL.
curl  -L https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64 -o /bin/jq
chmod +x /bin/jq
QUEUE_URL=$(jq -r '.QueueUrl' <<<"${QUEUE_INFO}")

# Populate the outputs
echo -n "${QUEUE_NAME}" > /tmp/queue-name
echo -n "${QUEUE_URL}" > /tmp/queue-url