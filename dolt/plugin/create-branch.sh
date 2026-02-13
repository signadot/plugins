#!/bin/bash
# exit when any command fails
set -e

echo "Creating Dolt branch for sandbox isolation"
echo "Sandbox name: ${SIGNADOT_SANDBOX_NAME}"
echo "Database: ${DOLT_DATABASE}"
echo "Host: ${DOLT_HOST}:${DOLT_PORT}"
echo "Base branch: ${BASE_BRANCH}"

# Install dependencies
apt-get update -qq && apt-get install -y -qq default-mysql-client curl ca-certificates > /dev/null 2>&1

# Install kubectl
curl -sLO "https://dl.k8s.io/release/$(curl -sL https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Read Dolt credentials from the Kubernetes Secret
DOLT_USER=$(kubectl get secret "${SECRET_NAME}" -o jsonpath='{.data.username}' | base64 -d)
DOLT_PASSWORD=$(kubectl get secret "${SECRET_NAME}" -o jsonpath='{.data.password}' | base64 -d)

# Sanitize sandbox name: remove hyphens to produce a valid Dolt branch name.
# Signadot sandbox names may contain hyphens (e.g., "fix-728"), but keeping
# branch names alphanumeric avoids parsing issues in Dolt.
SAFE_NAME=$(echo "${SIGNADOT_SANDBOX_NAME}" | tr -d '-')
BRANCH_NAME="sandbox${SAFE_NAME}"

# Create a new branch from the base branch using DOLT_BRANCH().
# Unlike DOLT_CHECKOUT('-b', ...), DOLT_BRANCH() creates the branch without
# switching the current session to it. This is safer in a multi-session server
# environment where other clients are connected.
mysql -h "${DOLT_HOST}" -P "${DOLT_PORT}" \
  -u "${DOLT_USER}" -p"${DOLT_PASSWORD}" "${DOLT_DATABASE}" \
  -e "CALL DOLT_BRANCH('${BRANCH_NAME}', '${BASE_BRANCH}');"

echo "Created Dolt branch: ${BRANCH_NAME} from ${BASE_BRANCH}"

# Set the sandbox branch as the default for the database.
# All new connections to the database will now read from this branch.
# This avoids the need to use database revision specifiers (e.g.,
# "dbname/branchname"), which can break certain MySQL drivers.
mysql -h "${DOLT_HOST}" -P "${DOLT_PORT}" \
  -u "${DOLT_USER}" -p"${DOLT_PASSWORD}" \
  -e "SET @@GLOBAL.${DOLT_DATABASE}_default_branch = '${BRANCH_NAME}';"

echo "Set default branch to: ${BRANCH_NAME}"

# Populate the outputs
mkdir -p /outputs
echo -n "${BRANCH_NAME}" > /outputs/branch-name
echo -n "${DOLT_DATABASE}" > /outputs/db-name
echo -n "${DOLT_HOST}" > /outputs/db-host
echo -n "${DOLT_PORT}" > /outputs/db-port