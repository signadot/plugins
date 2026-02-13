# Dolt Branch Plugin

This is a resource plugin that provisions an isolated [Dolt](https://www.dolthub.com/docs/) database branch for use within a sandbox.

Unlike the [MariaDB plugin](https://github.com/signadot/plugins/tree/main/mariadb) (which provisions an entire database server per sandbox), this plugin creates a lightweight branch on an existing Dolt SQL server. Dolt branches share storage through structural sharing, so each branch only consumes space for the rows it modifies.

## How It Works

When a sandbox is created:

1. The plugin reads Dolt credentials from a Kubernetes Secret.
2. It creates a new branch from the base branch using `DOLT_BRANCH()`.
3. It sets the new branch as the database's default branch via `@@GLOBAL.<db>_default_branch`.
4. All connections to the database now read from the sandbox branch.

When the sandbox is deleted:

1. The plugin resets the default branch to the base branch.
2. It force-deletes the sandbox branch with `DOLT_BRANCH('-D', ...)`.

## Prerequisites

- A running Dolt SQL server accessible via a Kubernetes Service
- A Kubernetes Secret containing the Dolt `username` and `password` keys

Example Secret:

```sh
kubectl create secret generic dolt-credentials \
  -n <namespace> \
  --from-literal=username=root \
  --from-literal=password=<your-password>
```

If you do not have a Dolt server running, deploy one with the manifests in `k8s/`:

```sh
kubectl apply -f ./k8s/dolt-init-data.yaml
kubectl apply -f ./k8s/dolt-server.yaml
kubectl rollout status deployment/dolt-db -n <namespace> --timeout=120s
```

## Installing the Plugin

1. Create the service account and RBAC permissions. The runner pod needs `get` access to the credentials Secret. Update the namespace in `k8s/dolt-rbac.yaml` before applying:

    ```sh
    kubectl apply -f ./k8s/dolt-rbac.yaml
    ```

2. Set `runner.namespace` in `plugin.yaml` to the namespace where Dolt is deployed, then register the plugin:

    ```sh
    signadot resourceplugin apply -f ./plugin.yaml
    ```

Everything else (host, port, database, secret name, base branch) is passed at sandbox creation time, so you do not need to modify `plugin.yaml` for different Dolt deployments.

## Using the Plugin

When creating a Signadot Sandbox, request an isolated Dolt branch by specifying the plugin name `dolt-branch` and passing the following parameters.

Parameter | Description | Example
--------- | ----------- | -------
`dbname` | Dolt database to branch | `location`
`dolt-host` | Dolt Service hostname | `dolt-db.hotrod.svc`
`dolt-port` | Dolt Service port | `3306`
`secret-name` | Kubernetes Secret with credentials | `dolt-credentials`
`base-branch` | Branch to fork from | `main`

After the resource is provisioned, the following output keys will be available for use by forked workloads in the sandbox:

Output Key | Description | Example
---------- | ----------- | -------
`createbranch.branch-name` | Name of the created branch | `sandboxmyfeature`
`createbranch.db-name` | Database name (unchanged) | `location`
`createbranch.db-host` | Dolt Service hostname | `dolt-db.hotrod.svc`
`createbranch.db-port` | Dolt Service port | `3306`

[`example-sandbox.yaml`](./example-sandbox.yaml) demonstrates a sandbox that uses this plugin:

```sh
signadot sandbox apply -f ./example-sandbox.yaml \
  --set cluster=<cluster-name> \
  --set namespace=<namespace> \
  --set dbname=location \
  --set dolt-host=dolt-db.<namespace>.svc \
  --set dolt-port=3306 \
  --set secret-name=dolt-credentials \
  --set base-branch=main
```

## Inspecting the Branch

While the sandbox is active, you can inspect the branch from inside the Dolt pod:

```sh
# List branches
kubectl exec -n <namespace> deploy/dolt-db -c dolt -- \
  bash -c "cd /var/lib/dolt/<dbname> && dolt branch -a"

# View commit history across all branches
kubectl exec -n <namespace> deploy/dolt-db -c dolt -- \
  bash -c "cd /var/lib/dolt/<dbname> && dolt log --all --oneline"

# Diff between base and sandbox branch
kubectl exec -n <namespace> deploy/dolt-db -c dolt -- \
  bash -c "cd /var/lib/dolt/<dbname> && dolt diff main <branch-name>"
```

## Removing the Plugin

Delete all sandboxes that reference the plugin first, then uninstall:

```sh
signadot resourceplugin delete dolt-branch
kubectl delete -f ./k8s/dolt-rbac.yaml
```

To also remove the Dolt server and its data:

```sh
kubectl delete -f ./k8s/dolt-server.yaml
kubectl delete -f ./k8s/dolt-init-data.yaml
kubectl delete secret dolt-credentials -n <namespace>
kubectl delete pvc dolt-data -n <namespace>
```