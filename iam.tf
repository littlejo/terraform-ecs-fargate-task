data "aws_partition" "current" {}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

locals {
  logs_arn = "arn:${data.aws_partition.current.partition}:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}"
  iam_arn = "arn:${data.aws_partition.current.partition}:iam::aws"
}

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
    effect    = "Allow"
    resources = ["${local.logs_arn}:log-group:${var.awslogs_group}:*"]
    actions   = ["logs:CreateLogStream", "logs:PutLogEvents"]
  }
}

data "aws_iam_policy_document" "s3_task_permissions" {
  statement {
    effect    = "Allow"
    resources = ["*"]
    actions   = ["s3:*"]
  }
}

resource "aws_iam_role" "execution" {
  name_prefix        = "execution-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

resource "aws_iam_role" "task" {
  name_prefix        = "task-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

resource "aws_iam_role_policy" "log_agent" {
  name_prefix   = "log-permissions"
  role   = aws_iam_role.task.id
  policy = data.aws_iam_policy_document.task_permissions.json
}

resource "aws_iam_role_policy" "s3_agent" {
  name_prefix   = "s3-permissions"
  role   = aws_iam_role.task.id
  policy = data.aws_iam_policy_document.s3_task_permissions.json
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy_attach" {
  role       = aws_iam_role.execution.name
  policy_arn = "${local.iam_arn}:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
