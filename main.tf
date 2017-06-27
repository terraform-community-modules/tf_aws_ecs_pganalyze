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
    env                   = "${var.env}"
    db_name               = "${var.db_name}"
    db_url                = "postgres://${var.db_username}:${var.db_password}@${var.rds_endpoint}/${var.db_name}"
    image                 = "${var.docker_image}"
    pga_api_key           = "${var.pga_api_key}"
    aws_instance_id       = "${var.aws_instance_id}" # we can almost certainly derive this
    aws_region            = "${data.aws_region.current.name}"
    awslogs_group         = "pganalyze-${var.env}"
    awslogs_region        = "${data.aws_region.current.name}"
    awslogs_stream_prefix = "${var.db_name}"
  }
}

data "aws_iam_policy_document" "pganalyze" {
  statement {
    actions = [
      "rds:Describe*",
      "rds:ListTagsForResource",
      "ec2:DescribeAccountAttributes",
      "ec2:DescribeAvailabilityZones",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeVpcs",
    ]

    resources = [
      "*",
    ]
  }

  statement {
    actions = [
      "cloudwatch:GetMetricStatistics",
      "logs:DescribeLogStreams",
      "logs:GetLogEvents",
    ]

    resources = [
      "*",
    ]
  }

  statement {
    actions = [
      "rds:DownloadDBLogFilePortion",
    ]

    resources = [
      "*",
    ]
  }
}

resource "aws_iam_role" "pganalyze" {
  name               = "pganalyze-${var.db_name}-${var.env}"
  path               = "/tf/pganalyze"
  assume_role_policy = "${data.aws_iam_policy_document.pganalyze.json}"
}

resource "aws_ecs_task_definition" "pganalyze" {
  family                = "pganalyze-${var.env}-${var.db_name}"
  container_definitions = "${data.template_file.pganalyze.rendered}"
  network_mode          = "bridge"
  task_role_arn         = "${aws_iam_role.pganalyze_task.arn}"
}

resource "aws_cloudwatch_log_group" "pganalyze" {
  name = "${aws_ecs_task_definition.pganalyze.family}"

  tags = {
    ecs_cluster = "${var.ecs_cluster}"
    Application = "${aws_ecs_task_definition.pganalyze.family}"
  }
}

resource "aws_ecs_service" "pganalyze" {
  name            = "pganalyze-${var.env}-${var.db_name}"
  cluster         = "${data.aws_ecs_cluster.ecs.arn}"
  task_definition = "${aws_ecs_task_definition.pganalyze.arn}"
  desired_count   = 1

  placement_strategy {
    type  = "binpack"
    field = "memory"
  }
}
