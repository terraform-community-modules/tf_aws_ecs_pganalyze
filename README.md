tf_aws_ecs_pganalyze
===========

Terraform module for deploying and managing [pganalyze collector](https://github.com/pganalyze/collector).

This module assumes that you already have an [ECS](https://aws.amazon.com/ecs/) cluster onto which you will deploy the collector.  Due to limitations in the collector, you must deploy one ECS service per database to be monitored by pganalyze.

You must also create a [CloudWatch Log Group](https://www.terraform.io/docs/providers/aws/r/cloudwatch_log_group.html) which will collect the log messages from the collector tasks.

----------------------
#### Required
- `ecs_cluster` - EC2 Container Service cluster in which the service will be deployed (must already exist, the module will not create it).
- `pga_api_key` - pganalyze API key (get this by defining the database server in the pganalyze console first).
- `task_identifier` - Unique identifier for the pganalyze task, used in naming resources.
- `db_username` - Username of pganalyze monitoring role.
- `db_password` - Password of pganalyze monitoring role.
- `db_name` - Name of database to be monitored.
- `rds_endpoint` - Endpoint of RDS instance to be monitored.
- `log_group` - CloudWatch log group to which container logs will be sent (must already exist, the module will not create it).

#### Optional
- `env` - environment tag, used in naming resources (default "dev").
- `docker_image` - Docker image specification containing pganalyze collector (default "quay.io/pganalyze/collector:stable", the upstream recommended value).
- `aws_instance_id` - passed to Docker container as an environment variable; seems to be ok to leave it blank?

Usage
-----

```hcl

module "pga_testdb" {
  source          = "github.com/terraform-community-modules/tf_aws_ecs_pganalyze?ref=v1.0.0"
  env             = "production"
  pga_api_key     = "ABCDEFGHIJLMNOP"
  task_identifier = "testdb-production"
  db_username     = "pganalyze"
  db_password     = "pganalyze_password"
  db_name         = "testdb"
  rds_endpoint    = "testdb.1234abcd.us-east-1.amazonaws.com"
  log_group       = "pganalyze"
  ...
}

```

Outputs
=======
None.

Authors
=======

[Steve Huff](https://github.com/hakamadare)

Changelog
=========

1.0.0 - Initial release.

License
=======

This software is released under the MIT License (see `LICENSE`).
