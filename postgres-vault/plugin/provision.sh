#!/bin/bash
# exit when any command fails
set -e

# Choose a database name that's globally unique.  The sandbox id
# and prefix signadot- should guarantee uniqueness with high probability.
NEW_DB_NAME="signadot-${SIGNADOT_RESOURCE_NAME}-${SIGNADOT_SANDBOX_ID}"

echo "Creating DB ${NEW_DB_NAME}"

# Load vault env vars
source /vault/secrets/db-access.sh

# Create the database
DB_INFO=$(psql --host=$DBHOST --port=$DBPORT --username=$DBUSER --command="CREATE DATABASE \"$NEW_DB_NAME\" WITH OWNER postgres")
echo "${DB_INFO}"

# Populate the output
echo -n "${NEW_DB_NAME}" > /tmp/db-name