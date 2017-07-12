data "aws_vpc" "vpc" {
  id = "${var.vpc_id}"
}

data "aws_ecs_cluster" "ecs" {
  cluster_name = "${var.ecs_cluster}"
}

data "aws_region" "current" {
  current = true
}

data "template_file" "pganalyze" {
  template = "${file("${path.module}/files/pganalyze.json")}"

  vars {
    task_identifier       = "${var.task_identifier}"
    db_url                = "postgres://${var.db_username}:${var.db_password}@${var.rds_endpoint}/${var.db_name}"
    image                 = "${var.docker_image}"
    pga_api_key           = "${var.pga_api_key}"
    aws_instance_id       = "${var.aws_instance_id}" # we can almost certainly derive this
    aws_region            = "${data.aws_region.current.name}"
    awslogs_group         = "pganalyze-${var.env}"
    awslogs_region        = "${data.aws_region.current.name}"
    awslogs_stream_prefix = "${var.task_identifier}"
  }
}

resource "aws_ecs_task_definition" "pganalyze" {
  family                = "pganalyze-${var.env}-${var.task_identifier}"
  container_definitions = "${data.template_file.pganalyze.rendered}"
  network_mode          = "bridge"
  task_role_arn         = "${aws_iam_role.pganalyze_task.arn}"
}

resource "aws_ecs_service" "pganalyze" {
  name            = "pganalyze-${var.env}-${var.task_identifier}"
  cluster         = "${data.aws_ecs_cluster.ecs.id}"
  task_definition = "${aws_ecs_task_definition.pganalyze.arn}"
  desired_count   = 1

  placement_strategy {
    type  = "binpack"
    field = "memory"
  }
}

resource "aws_cloudwatch_log_group" "ecs_task" {
  name = "pganalyze-${var.env}"
  retention_in_days = 3
}
