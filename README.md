# Signadot Plugins

## Overview

This repository contains a set of example plugins for use with Signadot.
You can take this as a base for developing your own Signadot Plugins.
For more information, please refer our documentation at [sandbox-resources](https://docs.signadot.com/docs/sandbox-resources)

- [`k8s-apply`](./k8s-apply/): A plugin to provision Kubernetes resources.
- [`mariadb`](./mariadb/): A plugin that provisions a temporary mariadb server.
- [`terraform`](./terraform/): A plugin that demonstrate how to use terraform to provision resources.
- [`postgres-vault`](./postgres-vault/): A plugin integrated with [hashicorp vault](https://www.vaultproject.io/) that provisions a temporary postgres database.
- [`amazon-sqs`](./amazon-sqs/): A plugin that provisions temporary queues in Amazon SQS.
- [`example-python`](./example-python/): An example plugin that runs arbitrary Python code during the creation and deletion of a sandbox.

## Using the examples

Each plugin contains usage documentation in a README.md.  You will need to have 
an active [Signadot installation](https://docs.signadot.com/docs/installation).

The directory [`example-baseline`](./example-baseline/) contains a sample deployment
that can be used to spin up sandboxes for each example.  Each example contains
a `example-sandbox.yaml` file that forks the example baseline.

## Community

To file an issue, please use our [community issue tracker](https://github.com/signadot/community/issues).

