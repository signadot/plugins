#!/bin/sh
# Drops this sandbox's branch. That removes only the branch's links to the
# shared parts: the source database keeps all of its data.
set -eu

curl -sS --fail-with-body -u "$CLICKHOUSE_USER:$CLICKHOUSE_PASSWORD" \
  "$CLICKHOUSE_URL" --data-binary "DROP DATABASE IF EXISTS $BRANCH_DATABASE SYNC"

echo "Dropped ClickHouse branch '$BRANCH_DATABASE'"
