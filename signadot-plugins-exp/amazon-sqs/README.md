# Amazon SQS Plugin

This is a resource plugin that provisions temporary queues in Amazon SQS
for use within a Signadot Sandbox.

## Installing the Plugin

Before installing the plugin, create a Kubernetes Secret called `aws-auth` in
the `signadot` namespace containing a `credentials` file in the format that the
`aws` CLI typically reads from `~/.aws/credentials`. For example, if you have a
`credentials` file prepared in the current directory:

```sh
kubectl -n signadot create secret generic aws-auth --from-file=credentials
```

See the [AWS CLI docs](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html#cli-configure-files-settings)
for more details on the `credentials` file format.

Make sure the target Kubernetes cluster already has Signadot Operator installed,
and then install this chart into the operator's namespace with Helm:

```sh
helm repo add signadot-plugins-exp https://plugins.signadot.com/exp
helm -n signadot install amazon-sqs-plugin signadot-plugins-exp/amazon-sqs
```

### Configuring the Plugin

The following values can be configured for this chart via `--set` or `values.yaml`:

Value | Description | Default
----- | ----------- | -------
`image` | The container image URL for the plugin | `signadot/amazon-sqs-plugin:{version}`
`imagePullPolicy` | The image pull policy for the plugin | `IfNotPresent`
`awsAuthSecret` | The name of the Secret object in the `signadot` namespace containing a `credentials` file (usually found at `~/.aws/credentials`) in the format expected by the `aws` CLI. | `aws-auth`

## Using the Plugin

When creating a Signadot Sandbox, you can request a temporary SQS queue from
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
`queue-name` | The name of the SQS queue that was created. | `signadot-k5ncuujcjllj2-MyResource`
`queue-url` | The URL of the SQS queue that was created. | `https://sqs.us-east-1.amazonaws.com/0123456789/signadot-k5ncuujcjllj2-MyResource`

## Removing the Plugin

Make sure all sandboxes that used the chart are deleted, so that the plugin gets
a chance to deprovision anything that was provisioned, and then use Helm to
uninstall the chart:

```sh
helm -n signadot uninstall amazon-sqs-plugin
```

## See Also

The source for this plugin is available in the [src](../../src/)
directory, but you don't need to build it from source in order to use it.
