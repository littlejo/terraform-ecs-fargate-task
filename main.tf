data "aws_vpc" "main" {
  default = true
}

data "aws_subnet_ids" "main" {
  vpc_id = data.aws_vpc.main.id
}

data "aws_security_groups" "main" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.main.id]
  }
}

data "aws_region" "current" {}

data "aws_partition" "current" {}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "task_permissions" {
  statement {
    effect = "Allow"

    resources = ["*"]

    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
  }
}

data "aws_iam_policy_document" "s3_task_permissions" {
  statement {
    effect = "Allow"

    resources = ["*"]

    actions = [
      "s3:*"
    ]
  }
}

resource "aws_ecs_cluster" "cluster" {
  name = var.ecs_cluster_name
}

module "this" {
  source                       = "cloudposse/ecs-container-definition/aws"
  container_name               = var.container_name
  container_image              = var.container_image
  container_memory             = 500
  container_memory_reservation = 100
  essential                    = true
  log_configuration = {
    logDriver = "awslogs"
    "options" = {
      "awslogs-group"         = var.awslogs_group,
      "awslogs-region"        = var.region,
      "awslogs-stream-prefix" = var.container_name
    }
  }
}

resource "aws_ecs_task_definition" "this" {
  family                   = var.family
  container_definitions    = module.this.json_map_encoded_list
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = aws_iam_role.execution.arn
  task_role_arn            = aws_iam_role.task.arn
}

resource "aws_iam_role" "execution" {
  name               = "execution-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

resource "aws_iam_role" "task" {
  name               = "task-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

resource "aws_iam_role_policy" "log_agent" {
  name   = "log-permissions"
  role   = aws_iam_role.task.id
  policy = data.aws_iam_policy_document.task_permissions.json
}

resource "aws_iam_role_policy" "s3_agent" {
  name   = "s3-permissions"
  role   = aws_iam_role.task.id
  policy = data.aws_iam_policy_document.s3_task_permissions.json
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy_attach" {
  role       = aws_iam_role.execution.name
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_cloudwatch_log_group" "this" {
  name = var.awslogs_group
}

