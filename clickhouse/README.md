# ClickHouse Branch Plugin

A [Signadot resource plugin](https://www.signadot.com/docs/reference/resource-plugins) that gives
every sandbox its own branch of a ClickHouse database. The branch is a new database on the same
ClickHouse server whose MergeTree tables are hard-linked to the source's data parts, so it is
ready in about a second and no data is copied. Tests in the sandbox can insert rows, run
`ALTER TABLE ... DELETE` or change the schema, and the shared database never changes.

Use it to test ClickHouse ingestion code, materialized views, schema migrations and backfills
against realistic data, with an isolated branch for every pull request, developer or coding
agent.

## How It Works

When a sandbox is created, the plugin connects to ClickHouse's HTTP interface and:

1. Creates a database named `<database>_<sandbox name>` on the same server.
2. Copies each MergeTree-family table's schema with `CREATE TABLE ... AS`, then attaches the
   table's newest partitions with `ALTER TABLE ... ATTACH PARTITION ID ... FROM`. On the same
   disk, ClickHouse attaches a partition by hard-linking its part files.
3. Recreates the source's materialized views, rewritten to read and write the branch's tables.
4. Outputs the branch's database name.

The sandbox's forked workloads receive that name as an environment variable and connect to the
branch. The baseline keeps using the source database.

MergeTree parts are immutable: inserts, merges, mutations and schema changes all write new
parts. So anything the sandbox writes goes into parts that only the branch uses, and the files
the branch shares with the source never change.

When the sandbox is deleted, the plugin drops the branch database. That removes only the
branch's links: the source keeps all of its data.

## Prerequisites

- A ClickHouse server that the cluster can reach over HTTP (port `8123` by default). The plugin
  was tested with ClickHouse 26.8.
- A ClickHouse user that can create and drop databases, and read `system.tables` and
  `system.parts`.
- A Kubernetes Secret named `clickhouse-credentials`, with the keys `username` and `password`,
  in the namespace the plugin runs in (`signadot` by default):

```bash
kubectl -n signadot create secret generic clickhouse-credentials \
  --from-literal=username=default --from-literal=password='<password>'
```

## Installation

1. Edit `plugin.yaml` and update:
   - `spec.runner.namespace`: Set to the namespace where the credentials Secret exists.
   - `CLICKHOUSE_URL`: Set to your ClickHouse HTTP endpoint (e.g., `http://clickhouse.default.svc:8123`).
   - `secretKeyRef.name`: Set to the Secret's name, if it is not `clickhouse-credentials`.

2. Apply the plugin:

```bash
signadot resourceplugin apply -f plugin.yaml
```

## Sandbox Parameters

| Parameter    | Description                                                                  | Example        |
|--------------|------------------------------------------------------------------------------|----------------|
| `database`   | Database to branch                                                           | `analytics`    |
| `partitions` | Optional. `all` (the default), or how many of each table's newest partitions to attach | `all`, `1`     |

Attaching a partition makes one hard link per file, so it is fast for any data size. Set
`partitions` to a small number for large tables anyway: while the branch exists, it keeps the
parts it attached on disk, even after the source merges or drops them.

## Plugin Outputs

| Output     | Description                      | Example                 |
|------------|----------------------------------|-------------------------|
| `database` | Name of the branch's database    | `analytics_my_sandbox`  |

## Usage

Reference the plugin in a sandbox spec, and pass the branch's name to the forked workload in
place of the source database:

```yaml
resources:
  - name: chdb
    plugin: clickhouse-branch
    params:
      database: analytics
      partitions: "all"

forks:
  - forkOf:
      kind: Deployment
      namespace: default
      name: usage-api
    customizations:
      env:
        - name: CLICKHOUSE_DATABASE
          valueFrom:
            resource:
              name: chdb
              outputKey: createbranch.database
```

### Try it with the example baseline

[`example-sandbox.yaml`](./example-sandbox.yaml) forks the
[`example-baseline`](../example-baseline/) application, which echoes its environment. Install the
baseline, then create the sandbox, replacing `<cluster-name>`, `<namespace>` and `<database>` with
your cluster's name, the baseline's namespace and a database on your ClickHouse server:

```bash
kubectl -n <namespace> apply -f ../example-baseline/k8s
signadot sandbox apply -f ./example-sandbox.yaml \
  --set cluster=<cluster-name> --set namespace=<namespace> --set database=<database>
```

The sandbox's preview endpoint shows `CLICKHOUSE_DATABASE` set to the branch, and
`SHOW DATABASES` in ClickHouse lists it.

For a full walkthrough with a service that reads and writes ClickHouse, see the
[ClickHouse database branching tutorial](https://github.com/signadot/examples/tree/main/clickhouse-branching-tutorial).

## Limitations

- The plugin targets a single ClickHouse server. A replicated cluster also needs `ON CLUSTER`
  and its own replication path for each branch's tables, which this plugin does not set up.
- It copies MergeTree-family tables and materialized views. Materialized views must write to a
  table named with `TO`. Views, dictionaries and tables with other engines are not copied.
- It picks the newest partitions by sorting partition IDs, which suits time-based partition
  keys such as `toYYYYMM(ts)`.
- Branches use disk for the parts they keep alive, so delete sandboxes when you're done, or give
  them a `ttl`.

## FAQ

### Does branching a ClickHouse database copy the data?

No. `ATTACH PARTITION ... FROM` between tables on the same disk hard-links the source's part
files. A branch uses new disk space only for what it writes, plus the source parts it keeps alive
after the source merges or drops them.

### How long does it take to create a branch?

Under a second in our tests. The time grows with the number of tables and partitions, not with
the size of the data.

### Can a sandbox change the shared database?

Not through its branch. Writes, `ALTER TABLE ... DELETE`, `UPDATE` and schema changes in the
branch create new parts for the branch's tables only, and dropping the branch removes only its
links.

### Does ClickHouse need the sandbox's routing key?

No. The forked workload connects to the branch database directly, so the routing key never
reaches ClickHouse. Signadot routes requests to the forked workload, and the workload picks the
branch through its environment.

## Removing the Plugin

Delete all sandboxes that use the plugin, so that it can drop their branches, then uninstall it:

```bash
signadot resourceplugin delete -f ./plugin.yaml
```

## File Structure

```
clickhouse/
├── plugin.yaml              # Resource Plugin specification
├── plugin/
│   ├── create-branch.sh     # Creates the branch database and attaches partitions
│   └── delete-branch.sh     # Drops the branch database
├── example-sandbox.yaml     # Example sandbox using the plugin
└── README.md
```
