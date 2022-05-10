# MariaDB Plugin

This is a resource plugin that provisions a temporary mariadb server for use
within a sandbox.
 

## Installing the Plugin

Make sure the target Kubernetes cluster already has Signadot Operator
installed, and then install this chart into the operator's namespace with Helm:

```sh
helm repo add signadot-plugins-exp https://plugins.signadot.com/exp
helm -n signadot install mariadb-plugin signadot-plugins-exp/mariadb
```

### Configuring the Plugin

The following values can be configured for this chart via `--set` or
`values.yaml`:

Value | Description | Default
----- | ----------- | -------
`image` | The container image URL for the plugin | `signadot/mariadb-plugin:{version}`
`imagePullPolicy` | The image pull policy for the plugin | `IfNotPresent`
`serviceAccountName` | The service account used to setup the mariadb instances | `sd-mariadb`

## Using the Plugin

When creating a Signadot Sandbox, you can request a temporary MariaDB instance
with a specified database name from this plugin by specifying the plugin name
`sd-mariadb` and passing the following parameters.

Parameter | Description | Example
--------- | ----------- | -------
`dbname` | The name of the empty database to create | `testdb`

After the resource is provisioned, the following output keys will be available
for use by forked workloads in the sandbox:

Output Key | Description | Example
---------- | ----------- | -------
`host` | The hostname of the database | `testdb-k5ncuujcjllj2.my-namespace.svc`
`port` | The port of the database | `3306`
`root_password` | The password for mariadb root access | `xxj87hd`

## Removing the Plugin

Make sure all sandboxes that used the chart are deleted, so that the plugin
gets a chance to deprovision anything that was provisioned, and then use Helm
to uninstall the chart:

```sh
helm -n signadot uninstall mariadb-plugin
```

## See Also

The source for this plugin is available in the [src](../../src/) directory, but
you don't need to build it from source in order to use it.
