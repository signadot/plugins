#!/bin/sh
# exit when any command fails
set -e

# Choose a bucket name that's globally unique.  The sandbox id
# and prefix signadot- should guarantee uniqueness with high probability.
BUCKET_NAME="signadot-${SIGNADOT_RESOURCE_NAME}-${SIGNADOT_SANDBOX_ID}"

# We will use S3 to store tfstate
TFSTATE_BUCKET="signadot-tfstate"
TFSTATE_KEY="${SIGNADOT_RESOURCE_NAME}-${SIGNADOT_SANDBOX_ID}/terraform.tfstate"

echo "Creating S3 Bucket"
echo "Sandbox id: ${SIGNADOT_SANDBOX_ID}"
echo "Resource name: ${SIGNADOT_RESOURCE_NAME}"
echo "Bucket name: ${BUCKET_NAME}"

# Clone the git repo
git clone https://github.com/signadot/plugins.git
cd plugins/terraform-amazon-s3/src/

# Run terraform apply
export TF_VAR_bucket_name="$BUCKET_NAME"
terraform init -backend-config="bucket=${TFSTATE_BUCKET}" -backend-config="key=${TFSTATE_KEY}"
terraform apply -auto-approve

# Populate the output
echo -n "${BUCKET_NAME}" > /tmp/bucket-name