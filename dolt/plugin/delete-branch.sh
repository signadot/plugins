#!/bin/bash
# exit when any command fails
set -e

echo "Deleting Dolt branch for sandbox cleanup"
echo "Branch: ${BRANCH_NAME}"
echo "Database: ${DOLT_DATABASE}"
echo "Host: ${DOLT_HOST}:${DOLT_PORT}"

# Install dependencies
apt-get update -qq && apt-get install -y -qq default-mysql-client curl ca-certificates > /dev/null 2>&1

# Install kubectl
curl -sLO "https://dl.k8s.io/release/$(curl -sL https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Read Dolt credentials from the Kubernetes Secret
DOLT_USER=$(kubectl get secret "${SECRET_NAME}" -o jsonpath='{.data.username}' | base64 -d)
DOLT_PASSWORD=$(kubectl get secret "${SECRET_NAME}" -o jsonpath='{.data.password}' | base64 -d)

# Reset the default branch to the base branch before deleting the sandbox branch.
mysql -h "${DOLT_HOST}" -P "${DOLT_PORT}" \
  -u "${DOLT_USER}" -p"${DOLT_PASSWORD}" \
  -e "SET @@GLOBAL.${DOLT_DATABASE}_default_branch = '${BASE_BRANCH}';"

echo "Reset default branch to: ${BASE_BRANCH}"

# Force-delete the sandbox branch using DOLT_BRANCH('-D', ...).
# The '-D' flag is necessary because the branch may contain commits
# that are not merged into the base branch (e.g., data fixes applied
# during testing). The standard '-d' flag would refuse to delete an
# unmerged branch.
mysql -h "${DOLT_HOST}" -P "${DOLT_PORT}" \
  -u "${DOLT_USER}" -p"${DOLT_PASSWORD}" "${DOLT_DATABASE}" \
  -e "CALL DOLT_BRANCH('-D', '${BRANCH_NAME}');"

echo "Deleted Dolt branch: ${BRANCH_NAME}"