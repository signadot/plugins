# PostgreSQL Vault Plugin

This is a multi-step resource plugin that:

1) Provisions a temporary postgres database for use within a Signadot Sandbox from an existing postgres service, such as Amazon Web Services' RDS.
2) Seeds the temporary database with some predefined data.

It uses:

- [Hashicorp vault](https://www.vaultproject.io/) to retrive the credentials needed to connect the postgres service.
- Git to clone a remote repository where the seeding data is located (see the [`example`](./example/) directory).

## Installing the Plugin

This example plugin, assumes you have a running Vault and have installed the [Vault Agent Injector](https://developer.hashicorp.com/vault/docs/platform/k8s/injector) in your cluster.
These are the steps required for configuring the plugin (replace `<user-name>`, `<password>`, `<db-host>` and `<db-port>` with the appropriate values):

```sh
# Create service account for running the exec units
kubectl create serviceaccount sd-postgresdb -n signadot

# Access one of the vault pods
kubectl exec -it pod/vault-0 -n vault -- sh

# Login into the vault
vault login
// insert the root token

# Create a key/value engine for storing the DB credentials
vault secrets enable -path=sd-postgresdb kv

# Populate the DB credentials for access the PG server (replace
# <user-name>, <password>, <db-host> and =<db-port>)
vault kv put sd-postgresdb/db-access \
  user=<user-name> \
  password=<password> \
  host=<db-host> \
  port=<db-port>

# Create a vault policy 
vault policy write sd-postgresdb-policy - <<EOF
path "sd-postgresdb/*" {
  capabilities = ["read"]
}
EOF

# Create a vault role (linked to the corresponding service account)
vault write auth/kubernetes/role/sd-postgresdb-role \
  bound_service_account_names=sd-postgresdb \
  bound_service_account_namespaces=signadot \
  policies=sd-postgresdb-policy \
  ttl=24h
```

Using the `signadot` CLI, register the plugin in Signadot Control Plane:

```sh
signadot resourceplugin apply -f ./plugin.yaml
```

## Using the Plugin

When creating a Signadot Sandbox, you can request a temporary postgres database from
this plugin by specifying the plugin name `postgres-vault`

After the resource is created, the following output keys will be available
for use by forked workloads in the sandbox:

Output Key | Description | Example
---------- | ----------- | -------
`provision.db-name` | The name of the database that was created. | `signadot-postgres-k5ncuujcjllj2`

[`example-sandbox.yaml`](./example-sandbox.yaml) is an example of a sandbox that uses this plugin.
To run it, you will need to install the [`example-baseline`](./../example-baseline/) application
in your cluster, and use `signadot` CLI to create the sandbox (replacing `<cluster-name>` with your
cluster name, and `<example-baseline-namespace>` with the namespace where `example-baseline` was deployed):

```sh
signadot sandbox apply -f ./example-sandbox.yaml --set cluster=<cluster-name> --set namespace=<example-baseline-namespace>
```

Now, in the [Signadot Dashboard](https://app.signadot.com/sandboxes), you can follow the status of your sandbox,
and once ready, you will be able to access the preview endpoint, where you will see the added env var:
`DB_NAME`.

## Removing the Plugin

Make sure all sandboxes that used the chart are deleted, so that the plugin gets
a chance to deprovision anything that was provisioned, and then use `signadot` CLI to uninstall the plugin:

```sh
signadot resourceplugin delete -f ./plugin.yaml
```