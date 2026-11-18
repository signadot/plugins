#!/bin/sh
# Creates this sandbox's branch of SOURCE_DATABASE: a new database on the same
# ClickHouse server whose tables share the source's data parts.
set -euo pipefail

# Runs one SQL statement through ClickHouse's HTTP interface.
ch() {
  curl -sS --fail-with-body -u "$CLICKHOUSE_USER:$CLICKHOUSE_PASSWORD" \
    "$CLICKHOUSE_URL" --data-binary "$1"
}

# SIGNADOT_SANDBOX_NAME is injected by the Signadot Operator. Hyphens become
# underscores so that the branch name is a plain ClickHouse identifier.
BRANCH="${SOURCE_DATABASE}_$(echo "$SIGNADOT_SANDBOX_NAME" | tr - _)"
PARTITIONS="${PARTITIONS:-all}"
LIMIT="LIMIT $PARTITIONS"; [ "$PARTITIONS" = all ] && LIMIT=""

# Only a plain identifier and a number reach the SQL below.
echo "$BRANCH" | grep -qE '^[A-Za-z_][A-Za-z0-9_]*$' || {
  echo "Invalid database name: '$SOURCE_DATABASE'" >&2; exit 1; }
echo "$PARTITIONS" | grep -qE '^(all|[0-9]+)$' || {
  echo "Invalid partitions: '$PARTITIONS' (use \"all\" or a number)" >&2; exit 1; }

# Each branch carries this comment. Never replace or drop a database without
# it: one that only happens to share the branch's name is not ours.
MARK="Signadot sandbox branch"
[ "$(ch "SELECT count() FROM system.databases WHERE name = '$BRANCH' AND comment != '$MARK'")" = 0 ] || {
  echo "Database '$BRANCH' exists and is not a sandbox branch; leaving it alone" >&2; exit 1; }

# If anything below fails, drop the partial branch, so that it never outlives
# a sandbox whose resource failed.
trap 'ch "DROP DATABASE IF EXISTS $BRANCH SYNC" || true' EXIT

# 1. Start from an empty database, so that a retried step never attaches the
#    same parts twice.
ch "DROP DATABASE IF EXISTS $BRANCH SYNC"
ch "CREATE DATABASE $BRANCH COMMENT '$MARK'"

# 2. Copy each MergeTree table's schema, then attach its newest partitions.
#    ATTACH PARTITION ... FROM hard-links the source's parts, so no data is
#    copied. Parts are immutable: inserts, mutations and merges in the branch
#    write new parts, and the source's files never change.
TABLES=$(ch "SELECT name FROM system.tables
             WHERE database = '$SOURCE_DATABASE' AND engine LIKE '%MergeTree'")
for t in $TABLES; do
  ch "CREATE TABLE $BRANCH.$t AS $SOURCE_DATABASE.$t"
  PARTS=$(ch "SELECT DISTINCT partition_id FROM system.parts
              WHERE database = '$SOURCE_DATABASE' AND table = '$t' AND active
              ORDER BY partition_id DESC $LIMIT")
  for p in $PARTS; do
    ch "ALTER TABLE $BRANCH.$t ATTACH PARTITION ID '$p' FROM $SOURCE_DATABASE.$t"
  done
  echo "$t: attached $(echo $PARTS | wc -w) partition(s)"
done

# 3. Recreate the materialized views, rewritten to read and write the branch's
#    tables instead of the source's.
ch "SELECT create_table_query FROM system.tables
    WHERE database = '$SOURCE_DATABASE' AND engine = 'MaterializedView' FORMAT TSVRaw" |
  sed "s/ $SOURCE_DATABASE\./ $BRANCH./g" |
  while IFS= read -r ddl; do ch "$ddl"; done

echo "Created ClickHouse branch '$BRANCH' from '$SOURCE_DATABASE'"

mkdir -p /outputs
echo -n "$BRANCH" > /outputs/database
trap - EXIT
