# Helm Charts for Signadot Plugins

This directory contains Helm charts for plugins.

There are two subdirectories: `signadot-plugins` for stable plugins
and `signadot-plugins-exp` for experimental plugins.

To install a plugin, add the Helm repo and then choose a plugin from
one of the subdirectories:

```sh
# Add the Helm chart repo.
helm repo add signadot-plugins https://plugins.signadot.com

# Install a stable plugin.
helm install <plugin> signadot-plugins/<plugin>

# Install an experimental plugin.
helm install <plugin> signadot-plugins-exp/<plugin>
```
