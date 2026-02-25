#!/bin/bash
set -e

apt-get update -qq && apt-get install -y -qq default-mysql-client > /dev/null 2>&1

# SIGNADOT_SANDBOX_NAME is injected by the Signadot Operator.
# Strip hyphens to produce a valid Dolt branch name.
SAFE_NAME=$(echo "${SIGNADOT_SANDBOX_NAME}" | tr -d '-')
BRANCH_NAME="sandbox${SAFE_NAME}"

# Create a new branch from the specified base branch.
mysql -h "${DOLT_HOST}" -P "${DOLT_PORT}" \
  -u "${DOLT_USER}" -p"${DOLT_PASSWORD}" "${DOLT_DATABASE}" \
  -e "CALL DOLT_BRANCH('${BRANCH_NAME}', '${BASE_BRANCH}');"

echo "Created Dolt branch '${BRANCH_NAME}' from '${BASE_BRANCH}'"

# Build the branch-qualified database name using the / separator.
# The / separator tells Dolt to route the connection to a specific branch.
# Example: "location/sandboxdoltsandboxdemo"
DB_NAME_WITH_BRANCH="${DOLT_DATABASE}/${BRANCH_NAME}"

mkdir -p /outputs
echo -n "${BRANCH_NAME}" > /outputs/branch-name
echo -n "${DB_NAME_WITH_BRANCH}" > /outputs/db-name
