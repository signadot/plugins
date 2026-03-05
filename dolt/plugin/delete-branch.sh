#!/bin/bash
set -e

apt-get update -qq && apt-get install -y -qq default-mysql-client > /dev/null 2>&1

# Force-delete the sandbox branch.
# -D is required because the branch may contain unmerged commits.
mysql -h "${DOLT_HOST}" -P "${DOLT_PORT}" \
  -u "${DOLT_USER}" -p"${DOLT_PASSWORD}" "${DOLT_DATABASE}" \
  -e "CALL DOLT_BRANCH('-D', '${BRANCH_NAME}');"

echo "Deleted Dolt branch '${BRANCH_NAME}'"
