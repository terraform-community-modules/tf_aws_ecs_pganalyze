variable "env" {
  description = "Environment tag (default 'dev')"
  default     = "dev"
}

variable "ecs_cluster" {
  description = "Name of ECS cluster in which the service will be deployed"
}

variable "docker_image" {
  description = "Docker image containing pganalyze collector (default is upstream stable)"
  default     = "quay.io/pganalyze/collector:stable"
}

variable "pga_api_key" {
  description = "pganalyze API key associated with database (register the database in the pganalyze console to obtain this)"
}

variable "aws_instance_id" {
  description = "some AWS instance id?"
}

variable "db_username" {
  description = "Username of pganalyze monitoring role"
}

variable "db_password" {
  description = "Password of pganalyze monitoring role"
}

variable "db_name" {
  description = "Name of database to be monitored"
}

variable "rds_endpoint" {
  description = "Endpoint of RDS instance to be monitored"
}
