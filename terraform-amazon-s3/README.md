# Terraform Amazon S3 Plugin

This is a resource plugin that provisions temporary Amazon S3 buckets
for use within a Signadot Sandbox.

It uses:

- Git to clone a remote repository where the provisioning code is located (see `src` directory).
- Terraform to create and populate the bucket with some sample files (see `assets` directory).

## Installing the Plugin

Before installing the plugin, create a Kubernetes Secret called `aws-auth` in
the `signadot` namespace containing a `credentials` file in the format that the
`aws` CLI typically reads from `~/.aws/credentials`. For example, if you have a
`credentials` file prepared in `/path/to/plugin-credentials`:

```sh
kubectl -n signadot create secret generic aws-auth --from-file=credentials=/path/to/plugin-credentials
```

These credentials will be used by Terraform to connect the AWS API.
See the [AWS CLI docs](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html#cli-configure-files-settings)
for more details on the `credentials` file format.

Using the `signadot` CLI, register the plugin in Signadot Control Plane:

```sh
signadot plugin apply -f ./plugin.yaml
```

## Using the Plugin

When creating a Signadot Sandbox, you can request a temporary S3 bucket from
this plugin by specifying the plugin name `terraform-amazon-s3` and passing the following input parameters.

Parameter | Description | Example
--------- | ----------- | -------
`region` (Required) | The AWS region in which to create the bucket | `us-east-1`

After the resource is created, the following output keys will be available
for use by forked workloads in the sandbox:

Output Key | Description | Example
---------- | ----------- | -------
`provision.bucket-name` | The name of the S3 bucket that was created. | `signadot-MyResource-k5ncuujcjllj2`

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