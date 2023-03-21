# Legacy MariaDB Ported Plugin

This is an example of how to port a legacy plugin (in this case the [legacy mariadb plugin](https://github.com/signadot/plugins/tree/legacy/signadot-plugins-exp/mariadb)) into the current format.

Here are some highlights about the convertion:

- The `runner.image` equals the [legacy plugin image](https://github.com/signadot/plugins/blob/206f2ba4421caf12d9cf024cd55ee64f7378728f/signadot-plugins-exp/mariadb/values.yaml#L1).
- The provision (`plugin/provision.sh`) and deprovision (`plugin/deprovision.sh`) scripts call `/signadot/plugin/bin/provision` and `/signadot/plugin/bin/deprovision` passing `SIGNADOT_SANDBOX_ID` and `SIGNADOT_RESOURCE_NAME` as arguments.
- The inputs are injected into `path: /signadot/plugin/input/<input-name>`
- The outputs are read from `/signadot/plugin/output/`


## Installing the Plugin

Before installing the plugin, create the required service account and RBAC permissions:

```sh
kubectl -n signadot create -f ./../mariadb/init/mariadb-init.yaml
```

Using the `signadot` CLI, register the plugin in Signadot Control Plane:

```sh
signadot plugin apply -f ./plugin.yaml
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
signadot plugin delete -f ./plugin.yaml
```

Finally delete the service account and RBAC permissions:

```sh
kubectl -n signadot delete -f ./../mariadb/init/mariadb-init.yaml
```