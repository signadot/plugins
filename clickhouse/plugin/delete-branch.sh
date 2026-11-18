#!/bin/sh
# Drops this sandbox's branch. That removes only the branch's links to the
# shared parts: the source database keeps all of its data.
set -eu

# Runs one SQL statement through ClickHouse's HTTP interface.
ch() {
  curl -sS --fail-with-body -u "$CLICKHOUSE_USER:$CLICKHOUSE_PASSWORD" \
    "$CLICKHOUSE_URL" --data-binary "$1"
}

# Drop the database only if it carries the comment that create-branch.sh sets.
MARK="Signadot sandbox branch"
if [ "$(ch "SELECT count() FROM system.databases
            WHERE name = '$BRANCH_DATABASE' AND comment = '$MARK'")" = 1 ]; then
  ch "DROP DATABASE $BRANCH_DATABASE SYNC"
  echo "Dropped ClickHouse branch '$BRANCH_DATABASE'"
else
  echo "No sandbox branch named '$BRANCH_DATABASE'; nothing to drop"
fi
