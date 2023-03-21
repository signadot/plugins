# RabbitMQ Plugin

This is a resource plugin that provisions temporary vhosts in RabbitMQ
for use within a Signadot Sandbox.

## Installing the Plugin

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

## Setting up the username and password in RabbitMQ

The following example sets up a username and password for authenticating
`rabbitmqadmin`

```sh
rabbitmqctl add_user test 123
rabbitmqctl set_user_tags test administrator 
rabbitmqctl set_permissions -p / test ".*" ".*" ".*"
```

The reader is referred to [the rabbitmq docs](https://www.rabbitmq.com/cli.html#remote-nodes)
for more information.

## Setting up the secret

The following command is an example of setting up a secret as needed to install the
plugin

```sh
kubectl -n signadot create secret generic rabbitmq-auth  \
	--from-literal=svc-namespace=rabbit \
	--from-literal=svc-name=rabbitmq \
	--from-literal=username=test \
	--from-literal=password=123
```

## Installing this plugin

Make sure the target Kubernetes cluster already has Signadot Operator installed,
and a rabbitmq stateful set running the management protocol.

```sh
helm repo add signadot-plugins-exp https://plugins.signadot.com/exp
helm -n signadot install rabbitmq-plugin signadot-plugins-exp/rabbitmq
```

## Using the Plugin

When creating a Signadot Sandbox, you can request a temporary rabbit mq vhost for
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

