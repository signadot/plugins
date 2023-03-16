# Signadot Plugins

This repository contains a list of example plugins for use with Signadot.
You can take this as a base for developing your own Signadot Plugins.
For more information, please refer our documentation at [sandbox-resources](https://docs.signadot.com/docs/sandbox-resources)

- `mariadb`: A plugin that provisions a temporary mariadb server.
- `terraform-amazon-s3`: A plugin that uses a terraform script to create an AWS S3 bucket.
- `postgres-vault`: A plugin integrated with [hashicorp vault](https://www.vaultproject.io/) that provisions a temporary postgres database.
- `amazon-sqs`: A plugin that provisions temporary queues in Amazon SQS.

If you are looking for the legacy plugins format, you can find it in the [`legacy` branch](https://github.com/signadot/plugins/tree/legacy).
Below, is an example of how to port a legacy plugin into the current format:

- `legacy-mariadb-ported`: Converts the [legacy mariadb plugin](https://github.com/signadot/plugins/tree/legacy/signadot-plugins-exp/mariadb) into the new format.

To file an issue, please use our [community issue tracker](https://github.com/signadot/community/issues).
