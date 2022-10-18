# Amazon S3 Plugin

This is a resource plugin that provisions temporary Amazon S3 buckets
for use within a Signadot Sandbox.

## Installing the Plugin

Before installing the plugin, create a Kubernetes Secret called `aws-auth` in
the `signadot` namespace containing a `credentials` file in the format that the
`aws` CLI typically reads from `~/.aws/credentials`. For example, if you have a
`credentials` file prepared in `/path/to/plugin-credentials`:

```sh
kubectl -n signadot create secret generic aws-auth --from-file=credentials=/path/to/plugin-credentials
```

See the [AWS CLI docs](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html#cli-configure-files-settings)
for more details on the `credentials` file format.

Make sure the target Kubernetes cluster already has Signadot Operator installed,
and then install this chart into the operator's namespace with Helm:

```sh
helm repo add signadot-plugins-exp https://plugins.signadot.com/exp
helm -n signadot install amazon-s3-plugin signadot-plugins-exp/amazon-s3
```

### Configuring the Plugin

The following values can be configured for this chart via `--set` or `values.yaml`:

Value | Description | Default
----- | ----------- | -------
`image` | The container image URL for the plugin | `signadot/amazon-s3-plugin:{version}`
`imagePullPolicy` | The image pull policy for the plugin | `IfNotPresent`
`awsAuthSecret` | The name of the Secret object in the `signadot` namespace containing a `credentials` file (usually found at `~/.aws/credentials`) in the format expected by the `aws` CLI. | `aws-auth`

## Using the Plugin

When creating a Signadot Sandbox, you can request a temporary S3 bucket from
this plugin by specifying the plugin name `sd-amazon-s3` (note the `sd-` prefix)
and passing the following input parameters.

Parameter | Description | Example
--------- | ----------- | -------
`region` (Required) | The AWS region in which to create the bucket | `us-east-1`
`args` | Optional extra arguments to pass to the `aws s3 mb` command. See the [command reference](https://awscli.amazonaws.com/v2/documentation/api/latest/reference/s3/mb.html) for details. | `--object-lock-enabled-for-bucket`

After the resource is provisioned, the following output keys will be available
for use by forked workloads in the sandbox:

Output Key | Description | Example
---------- | ----------- | -------
`bucket-name` | The name of the S3 bucket that was created. | `signadot-MyResource-k5ncuujcjllj2`

## Removing the Plugin

Make sure all sandboxes that used the chart are deleted, so that the plugin gets
a chance to deprovision anything that was provisioned, and then use Helm to
uninstall the chart:

```sh
helm -n signadot uninstall amazon-s3-plugin
```

## See Also

The source for this plugin is available in the [src](../../src/)
directory, but you don't need to build it from source in order to use it.