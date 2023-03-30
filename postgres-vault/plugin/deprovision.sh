#!/bin/bash
# exit when any command fails
set -e

echo "Deleting DB ${DB_NAME}"

# Load vault env vars
source /vault/secrets/db-access.sh

# Revoke new DB connections, close all current connections and delete the database
psql --host=$DBHOST --port=$DBPORT --username=$DBUSER << EOF
REVOKE CONNECT ON DATABASE "$DB_NAME" FROM public;
SELECT pid, pg_terminate_backend(pid) 
FROM pg_stat_activity 
WHERE datname = '$DB_NAME' AND pid <> pg_backend_pid();
DROP DATABASE "$DB_NAME";
EOF