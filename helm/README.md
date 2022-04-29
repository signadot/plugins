# Helm Charts for Signadot Plugins

This directory contains Helm charts for plugins.

There are two subdirectories: `resource-plugins` for stable plugins
and `resource-plugins-exp` for experimental resource plugins.

In the future, we may add other directories for other types of plugins.  For
the moment, there is only one kind of plugin: [Resource
Plugins](https://docs.signadot.com/docs/resource-plugins).

To install a plugin, add the Helm repo and then choose a plugin from
one of the subdirectories:

```sh
# Add the Helm chart repo.
helm repo add signadot-plugins https://plugins.signadot.com

# Install a stable plugin.
helm install <plugin> resource-plugins/<plugin>

# Install an experimental plugin.
helm install <plugin> resource-plugins-exp/<plugin>
```
