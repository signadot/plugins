# Amazon SQS Plugin

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
`postgresAuthSecret` | The name of the Secret object in the `signadot` namespace containing a `credentials` file (usually found at `~/.aws/credentials`) in the format expected by the `aws` CLI. | `aws-auth`

## Using the Plugin

When creating a Signadot Sandbox, you can request a temporary 
this plugin by specifying the plugin name `sd-amazon-sqs` (note the `sd-` prefix)
and passing the following input parameters.

Parameter | Description | Example
--------- | ----------- | -------
`region` (Required) | The AWS region in which to create the queue | `us-east-1`
`attributes` | Optional value to pass to the `aws sqs create-queue` command's `--attributes` flag. See the [command reference](https://docs.aws.amazon.com/cli/latest/reference/sqs/create-queue.html) for details. | `DelaySeconds=30`
`tags` | Optional value to pass to the `aws sqs create-queu` command's `--tags` flag. See the [command reference](https://docs.aws.amazon.com/cli/latest/reference/sqs/create-queue.html) for details. | `MyTag=value,Tag2=value`

After the resource is provisioned, the following output keys will be available
for use by forked workloads in the sandbox:

Output Key | Description | Example
---------- | ----------- | -------
`database-name` | The name of the database that was created. | `signadot-postgres-k5ncuujcjllj2`

## Removing the Plugin

Make sure all sandboxes that used the chart are deleted, so that the plugin gets
a chance to deprovision anything that was provisioned, and then use Helm to
uninstall the chart:

```sh
helm -n signadot uninstall postgres-plugin
```

## See Also

The source for this plugin is available in the [src](../../src/)
directory, but you don't need to build it from source in order to use it.
