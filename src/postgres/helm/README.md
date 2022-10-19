# PostgreSQL Plugin

This is a resource plugin that provisions a temporary postgres database for use
within a Signadot Sandbox from an existing postgres service, such as Amazon Web
Services' RDS.

## Installing the Plugin

Make sure the target Kubernetes cluster already has Signadot Operator
installed.

Before installing the plugin, you will need to create a Kubernetes Secret in
the `signadot` namespace containing information about how the plugin will
connect to the database.

For example
```sh
kubectl -n signadot create secret generic postgres-auth \
    --from-literal=user=postgres \
    --from-literal=password=xyz \
    --from-literal=host=demo-test-1.cykz7h9jhlso.us-west-1.rds.amazonaws.com \
    --from-literal=port=5432
```

All of the keys are required.

Then install this plugin with helm:
```sh
helm repo add signadot-plugins-exp https://plugins.signadot.com/exp
helm -n signadot install postgres-plugin signadot-plugins-exp/postgres
```

### Configuring the Plugin

The following values can be configured for this chart via `--set` or `values.yaml`:

Value | Description | Default
----- | ----------- | -------
`image` | The container image URL for the plugin | `signadot/amazon-sqs-plugin:{version}`
`imagePullPolicy` | The image pull policy for the plugin | `IfNotPresent`
`postgresAuthSecret` | The name of the Secret object in the `signadot` namespace containing the secret described above. | `postgres-auth`

## Using the Plugin

When creating a Signadot Sandbox, you can request a temporary database from the
postgres server this plugin is configured to use:

```yaml
name: test-postgres
spec:
  cluster: staging
  resources:
  - name: psql
    plugin: sd-postgres
  forks:                                      # set of workloads to fork and how to fork.
  - forkOf:                                   # what to fork
      kind: Deployment                        # K8s Kind of workload to fork (Deployment or ArgoRollout).
      name: customer                          # K8s name of workload to fork.
      namespace: staging
    customizations:                           # how to fork the workload specified by forkOf
      env:                                    # define environment for containers in fork.
      - name: DBHOST                          # environmental variable name.
        valueFrom:                            # dynamic value, determined when the fork is created.
          resource:                           # value taken from sandbox resource
            name: psql                        # the resource is named 'testdb' in this sandbox.
            outputKey: db-name                # the resource plugin provides a value for this key.
```

After the resource is provisioned, the following output keys will be available
for use by forked workloads in the sandbox:

Output Key | Description | Example
---------- | ----------- | -------
`db-name` | The name of the database that was created. | `signadot-postgres-k5ncuujcjllj2`

These can be injected into the workload as in the example above.

## Removing the Plugin

Make sure all sandboxes that used the chart are deleted, so that the plugin gets
a chance to deprovision anything that was provisioned, and then use Helm to
uninstall the chart:

```sh
helm -n signadot uninstall postgres-plugin
```

finally, delete the secret:

```sh
kubectl -n signadot delete secret postgres-auth
```

## See Also

The source for this plugin is available in the [src](../../src/)
directory, but you don't need to build it from source in order to use it.
