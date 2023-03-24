# Terraform Amazon SQS Plugin

This is a resource plugin that provisions temporary queues in Amazon SQS
for use within a Signadot Sandbox.

## Installing the Plugin

Before installing the plugin, create a Kubernetes Secret called `aws-auth` in
the `signadot` namespace containing a `credentials` file in the format that the
`aws` CLI typically reads from `~/.aws/credentials`. For example, if you have a
`credentials` file prepared in `/path/to/plugin-credentials`:

```sh
kubectl -n signadot create secret generic aws-auth --from-file=credentials=/path/to/plugin-credentials
```

These credentials will be used by `aws` CLI to connect the AWS API.
See the [AWS CLI docs](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html#cli-configure-files-settings)
for more details on the `credentials` file format.

Using the `signadot` CLI, register the plugin in Signadot Control Plane:

```sh
signadot plugin apply -f ./plugin.yaml
```

## Using the Plugin

When creating a Signadot Sandbox, you can request a temporary SQS queue from
this plugin by specifying the plugin name `amazon-sqs` and passing the following input parameters.

Parameter | Description | Example
--------- | ----------- | -------
`region` (Required) | The AWS region in which to create the queue | `us-east-1`
`attributes` | Optional value to pass to the `aws sqs create-queue` command's `--attributes` flag. See the [command reference](https://docs.aws.amazon.com/cli/latest/reference/sqs/create-queue.html) for details. | `DelaySeconds=30`
`tags` | Optional value to pass to the `aws sqs create-queue` command's `--tags` flag. See the [command reference](https://docs.aws.amazon.com/cli/latest/reference/sqs/create-queue.html) for details. | `MyTag=value,Tag2=value`

After the resource is provisioned, the following output keys will be available
for use by forked workloads in the sandbox:

Output Key | Description | Example
---------- | ----------- | -------
`provision.queue-name` | The name of the SQS queue that was created. | `signadot-MyResource-k5ncuujcjllj2`
`provision.queue-url` | The URL of the SQS queue that was created. | `https://sqs.us-east-1.amazonaws.com/0123456789/signadot-k5ncuujcjllj2-MyResource`

## Removing the Plugin

Make sure all sandboxes that used the chart are deleted, so that the plugin gets
a chance to deprovision anything that was provisioned, and then use `signadot` CLI to uninstall the plugin:

```sh
signadot plugin delete -f ./plugin.yaml
```

Finally delete the `aws-auth` secret from `signadot` namespace:

```sh
kubectl -n signadot delete secret aws-auth
```