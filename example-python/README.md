# Example Python Plugin

This is an example of a plugin that allows you to write arbitrary Python code
to execute during the creation and deletion of a sandbox.

## Installing the Plugin

Using the `signadot` CLI, create the plugin using:

```sh
signadot resourceplugin apply -f ./plugin.yaml
```

## Using the Plugin

The following is a self-contained specification of an example sandbox that you
can use to create the above plugin. Note that before this sandbox brings up any
workloads, it will execute the Python code in the `create` section of the plugin
within a new pod, and when sandbox deletion is triggered, the `delete` script
will be triggered from a new pod that is created.

```yaml
name: "sandbox-test-python-plugin"
spec:
  description: sandbox with python plugin
  cluster: "xyz"
  resources:
  - name: python
    plugin:  python-plugin
```

## Removing the Plugin

Make sure all sandboxes that used the chart are deleted, so that the plugin gets
a chance to deprovision anything that was provisioned, and then use `signadot` CLI to uninstall the plugin:

```sh
signadot resourceplugin delete -f ./plugin.yaml
```
