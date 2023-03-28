# Terraform Plugin

This is a resource plugin that demonstrate how to use terraform to provision the needfull resources
for running a sandbox.

As part of this example, and just for demonstration purposes, we will use the terraform `aws provider`
to create (and delete) a temporary Amazon S3 bucket.

If you check [plugin/provision.sh](./plugin/provision.sh),
you will notice the terraform scripts to be executed were not included as part of the resource plugin itself, instead they
are cloned from a remote Git repository (https://github.com/signadot/plugins.git) which in this case, it happens to
match with the current repository, but could perfectly be a different one.
This pattern allows a better flexibility and separation of concerns (we could even make the `branch` or `tag`
to be cloned an input paramter for this plugin).

An important fact to consider is that the terraform state should be shared among the create and delete
steps, which will execute on different pods, so some sort of shared storage will be required for this plugin
to properly work (maybe just a simple PVC, being that the `provision` and `deprovision` pods will never execute
concurrently). In this example, given we are already using the `aws provider`, and thus have access to AWS,
we are using the `s3 backend`.

## Installing the Plugin

Before installing the plugin, you will need to setup the AWS credentials to be used by terraform.
To do so, create a Kubernetes Secret called `aws-auth` in the `signadot` namespace
containing a `credentials` file in the format that the `aws` CLI typically reads from `~/.aws/credentials`.
For example, if you have a `credentials` file prepared in `/path/to/plugin-credentials`:

```sh
kubectl -n signadot create secret generic aws-auth --from-file=credentials=/path/to/plugin-credentials
```

See the [AWS CLI docs](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html#cli-configure-files-settings)
for more details on the `credentials` file format.

Next, you will need to define the bucket name to be used for storing the terraform states (and in case you want
to use a new bucket, you should create it). The `tfstate` objects will be stored under the following path:

`<resource-name>-<sandbox-id>/terraform.tfstate"`


Finally, using the `signadot` CLI, register the plugin in Signadot Control Plane (replace `<tfstate-bucket>` with
the selected bucket name):

```sh
signadot resourceplugin apply -f ./plugin.yaml --set tfstate-bucket=<tfstate-bucket>
```

## Using the Plugin

When creating a Signadot Sandbox, you can request a temporary S3 bucket from
this plugin by specifying the plugin name `terraform` and passing the following input parameters.

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
signadot resourceplugin delete terraform
```

Finally delete the `aws-auth` secret from `signadot` namespace:

```sh
kubectl -n signadot delete secret aws-auth
```