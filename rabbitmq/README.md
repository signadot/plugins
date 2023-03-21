# RabbitMQ Plugin

This is a resource plugin that provisions temporary virtual hosts in RabbitMQ
for use within a Signadot Sandbox.  Each temporary virtual host is a unique
clone of a reference virtual host, specified in a Signadot Sandbox spec. Each
Signadot Sandbox also provides a list of rabbitmq users, and those users are
provided access to the temporary virtual host by this plugin.

For more information about RabbitMQ virtual hosts, please see
https://www.rabbitmq.com/vhosts.html

## Installing the Plugin

This plugin is installed using the [signadot cli](https://docs.signadot.com/docs/cli) 
by calling
```
signadot resourceplugin apply -f plugin.yaml
```

However, the plugin assumes certain things exist when it is used by a sandbox,
in your cluster.

You will need a kubernetes cluster with the Signadot operator and RabbitMQ
running the admin api (such as is found
[here](https://github.com/bitnami/charts/tree/master/bitnami/rabbitmq)).

Before installing the plugin, create a Kubernetes Secret called `rabbitmq-auth` in
the `signadot` namespace containing the 4 keys 
- `svc-namespace`: the namespace in which the rabbit mq service exists.
- `svc-name`: the name of the rabbitmq service.
- `username`: the username with which to autheticate with `rabbitmqadmin`
to create the vhost.
- `password`: the password with which to autheticate with `rabbitmqadmin`
to create the vhost.

The following command is an example of setting up a secret as needed to install the
plugin

```sh
kubectl -n signadot create secret generic rabbitmq-auth  \
	--from-literal=svc-namespace=rabbit \
	--from-literal=svc-name=rabbitmq \
	--from-literal=username=test \
	--from-literal=password=123
```

### Setting up the username and password in RabbitMQ

If you are creating this plugin to run as a specific RabbitMQ user, you may
wish to create the user.  The following example sets up a username and password
for authenticating `rabbitmqadmin`

```sh
rabbitmqctl add_user test 123
rabbitmqctl set_user_tags test administrator 
rabbitmqctl set_permissions -p / test ".*" ".*" ".*"
```

The reader is referred to [the rabbitmq docs](https://www.rabbitmq.com/cli.html#remote-nodes)
for more information.


## Using the Plugin

When creating a Signadot Sandbox, you can request a temporary rabbit mq virtual host for
an existing set of rabbitmq users from this plugin by specifying the plugin name 
`sd-rabbitmq` and passing the following input parameters.

Parameter | Description | Example
--------- | ----------- | -------
`refvhost` | The rabbitmq `vhost` to clone for users | `/`
`users` | Comma separated list of the user names which will access the provsioned vhost | `dev,james`

After the resource is provisioned, the following output keys will be available
for use by forked workloads in the sandbox:

Output Key | Description | Example
---------- | ----------- | -------
`vhost-name` | The name of the vhost queue that was created as a clone of ${refvhost} | `sd-vhost-k5ncuujcjllj2`

## Removing the Plugin

Make sure all sandboxes that used the chart are deleted, so that the plugin gets
a chance to deprovision anything that was provisioned, and then use Helm to
uninstall the plugin:

```sh
signadot resourceplugin delete rabbitmq
```

You may want to delete the secret `rabbitmq-auth` as well.


