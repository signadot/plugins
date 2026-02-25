# Dolt Branch Plugin

A [Signadot Resource Plugin](https://docs.signadot.com/docs/reference/resource-plugins) that provisions isolated [Dolt](https://docs.dolthub.com/) database branches for sandbox testing.

## How It Works

When a sandbox is created, the plugin:

1. Creates a new Dolt branch from the specified base branch (e.g., `main`).
2. Outputs the branch-qualified database name (e.g., `location/sandboxdoltsandboxdemo`).

The sandbox pod receives the branch-qualified name as an environment variable. The MySQL-compatible driver passes it directly to Dolt, which routes the connection to the sandbox branch. The baseline pods connect with the plain database name (e.g., `location`), so Dolt serves the default `main` branch.

When the sandbox is deleted, the plugin force-deletes the branch.

## Prerequisites

- A Dolt SQL server running in your Kubernetes cluster.
- A Kubernetes Secret containing Dolt credentials with keys `username` and `password`.

## Installation

1. Edit `plugin.yaml` and update:
   - `spec.runner.namespace`: Set to the namespace where the Dolt credentials Secret exists.
   - `DOLT_HOST`: Set to the Dolt Service DNS name (e.g., `dolt-db.default.svc`).
   - `DOLT_PORT`: Set to the Dolt Service port (default `3306`).
   - `secretKeyRef.name`: Set to the name of the Kubernetes Secret containing Dolt credentials.

2. Apply the plugin:

```bash
signadot resourceplugin apply -f plugin.yaml
```

## Sandbox Parameters

| Parameter     | Description                                | Example    |
|---------------|--------------------------------------------|------------|
| `dbname`      | Dolt database name                         | `location` |
| `base-branch` | Branch to create the sandbox branch from   | `main`     |

## Plugin Outputs

| Output        | Description                                           | Example                              |
|---------------|-------------------------------------------------------|--------------------------------------|
| `branch-name` | Name of the created Dolt branch                      | `sandboxdoltsandboxdemo`             |
| `db-name`     | Branch-qualified database name (`database/branch`)    | `location/sandboxdoltsandboxdemo`    |

## Usage

Reference the plugin in a sandbox spec:

```yaml
resources:
  - name: doltdb
    plugin: dolt-branch
    params:
      dbname: location
      base-branch: main

forks:
  - forkOf:
      kind: Deployment
      namespace: default
      name: location-service
    customizations:
      env:
        - name: MYSQL_DBNAME
          container: location
          valueFrom:
            resource:
              name: doltdb
              outputKey: createbranch.db-name
```

See `example-sandbox.yaml` for a complete example.

## File Structure

```
dolt/
├── plugin.yaml              # Resource Plugin specification
├── plugin/
│   ├── create-branch.sh     # Creates a Dolt branch from base-branch
│   └── delete-branch.sh     # Force-deletes the sandbox branch
├── example-sandbox.yaml     # Example sandbox using the plugin
└── README.md
```
