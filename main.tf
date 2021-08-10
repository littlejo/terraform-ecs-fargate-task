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
  name = "unzip-cluster"
}

module "this" {
  source                       = "cloudposse/ecs-container-definition/aws"
  container_name               = "unzip"
  container_image              = "littlejo/unzip-s3:bash"
  container_memory             = 500
  container_memory_reservation = 100
  essential                    = true
  log_configuration = {
    logDriver = "awslogs"
    "options" = {
      "awslogs-group"         = "/ecs-cluster/services/unzip",
      "awslogs-region"        = var.region,
      "awslogs-stream-prefix" = "unzip"
    }
  }
}

resource "aws_ecs_task_definition" "this" {
  family                = "unzip-tf"
  container_definitions = module.this.json_map_encoded_list
  network_mode          = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = aws_iam_role.execution.arn
  task_role_arn            = aws_iam_role.task.arn
}

resource "aws_iam_role" "execution" {
  name               = "test-execution-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

resource "aws_iam_role" "task" {
  name               = "test-task-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

resource "aws_iam_role_policy" "log_agent" {
  name   = "test-log-permissions"
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
  name = "/ecs-cluster/services/unzip"

  tags = {
    Environment = "production"
    Application = "serviceA"
  }
}

