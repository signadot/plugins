# MariaDB Plugin

This is a resource plugin that provisions a temporary mariadb server for use within a sandbox.

## Installing the Plugin

Before installing the plugin, create the required service account and RBAC permissions:

```sh
kubectl -n signadot create -f ./k8s/mariadb-init.yaml
```

Using the `signadot` CLI, register the plugin in Signadot Control Plane:

```sh
signadot resourceplugin apply -f ./plugin.yaml
```

## Using the Plugin

When creating a Signadot Sandbox, you can request a temporary MariaDB instance
with a specified database name from this plugin by specifying the plugin name
`mariadb` and passing the following parameters.

Parameter | Description | Example
--------- | ----------- | -------
`dbname` | The name of the empty database to create | `testdb`

After the resource is provisioned, the following output keys will be available
for use by forked workloads in the sandbox:

Output Key | Description | Example
---------- | ----------- | -------
`provision.host` | The hostname of the database | `testdb-k5ncuujcjllj2.my-namespace.svc`
`provision.port` | The port of the database | `3306`
`provision.root-password` | The password for mariadb root access | `xxj87hd`


## Removing the Plugin

Make sure all sandboxes that used the chart are deleted, so that the plugin gets
a chance to deprovision anything that was provisioned, and then use `signadot` CLI to uninstall the plugin:

```sh
signadot resourceplugin delete -f ./plugin.yaml
```

Finally delete the service account and RBAC permissions:

```sh
kubectl -n signadot delete -f ./k8s/mariadb-init.yaml
```