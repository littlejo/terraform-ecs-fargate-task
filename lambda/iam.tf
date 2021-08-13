data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

locals {
  logs_arn = "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}"
}

data "aws_iam_policy_document" "log" {
  statement {
    actions   = ["logs:CreateLogStream", "logs:PutLogEvents"]
    resources = ["${local.logs_arn}:log-group:/aws/lambda/${var.function_name}:*"]
  }
  statement {
    actions   = ["logs:CreateLogGroup"]
    resources = ["${local.logs_arn}:*"]
  }
}

data "aws_iam_policy_document" "ecs" {
  statement {
    actions   = ["ecs:RunTask", "iam:PassRole"]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "this" {
  name               = "Lambda_role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_policy" "log" {
  name        = "lambda_cloudwatch"
  description = "Allow lambda to modify cloudwatch logs"
  policy      = data.aws_iam_policy_document.log.json
}

resource "aws_iam_policy" "ecs" {
  name        = "lambda_ecs"
  description = "Allow lambda to run ecs task"
  policy      = data.aws_iam_policy_document.ecs.json
}

resource "aws_iam_role_policy_attachment" "log" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.log.arn
}

resource "aws_iam_role_policy_attachment" "ecs" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.ecs.arn
}
