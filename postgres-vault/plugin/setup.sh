#!/bin/bash
# exit when any command fails
set -e

# Install the git client
apt update; apt install -y git

# Clone the git repo
git clone https://github.com/signadot/plugins.git
cd plugins/postgres-vault/data/

echo "Populating DB ${DB_NAME}"

# Load vault env vars
source /vault/secrets/db-access.sh

# Populate the database
psql --host=$DBHOST --port=$DBPORT --username=$DBUSER --dbname=$DB_NAME --file=world.sql