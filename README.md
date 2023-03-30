# Signadot Plugins

## Overview

This repository contains a set of example plugins for use with Signadot.
You can take this as a base for developing your own Signadot Plugins.
For more information, please refer our documentation at [sandbox-resources](https://docs.signadot.com/docs/sandbox-resources)

- [`mariadb`](./mariadb/): A plugin that provisions a temporary mariadb server.
- [`terraform`](./terraform/): A plugin that demonstrate how to use terraform to provision resources.
- [`postgres-vault`](./postgres-vault/): A plugin integrated with [hashicorp vault](https://www.vaultproject.io/) that provisions a temporary postgres database.
- [`amazon-sqs`](./amazon-sqs/): A plugin that provisions temporary queues in Amazon SQS.


## Using the examples

Each plugin contains usage documentation in a README.md.  You will need to have 
an active [Signadot installation](https://docs.signadot.com/docs/installation).

The directory [`example-baseline`](./example-baseline/) contains a sample deployment
that can be used to spin up sandboxes for each example.  Each example contains
a `example-sandbox.yaml` file that forks the example baseline.


## Porting old plugins

Since March 2023, this repository contains plugins for a new and improved resource plugin system, which differs substantially from the old, legacy system.

If you are looking for the legacy plugins format, you can find it in the [`legacy` branch](https://github.com/signadot/plugins/tree/legacy).

If you'd like to translate an old plugin into the new system, below is an
example of how to port a legacy plugin into the current format:

- [`port-old2new-example`](./port-old2new-example/): Converts the [legacy mariadb plugin](https://github.com/signadot/plugins/tree/legacy/signadot-plugins-exp/mariadb) into the new format.

## Community

To file an issue, please use our [community issue tracker](https://github.com/signadot/community/issues).

