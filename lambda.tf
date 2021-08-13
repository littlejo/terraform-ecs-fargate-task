data "template_file" "this" {
  template = file("${path.module}/lambda/create_task.py.tpl")
  vars = {
    default_sg     = data.aws_security_groups.main.ids[0]
    default_subnet = tolist(data.aws_subnet_ids.main.ids)[0]
    family         = "${var.family}:${aws_ecs_task_definition.this.revision}"
    container_name = var.container_name
  }
}

data "archive_file" "this" {
  type                    = "zip"
  source_content          = data.template_file.this.rendered
  source_content_filename = "lambda_function.py"
  output_path             = "${path.module}/lambda.zip"
}

data "aws_iam_policy_document" "log" {
  statement {
    actions   = ["logs:CreateLogStream", "logs:PutLogEvents"]
    resources = ["*"]
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

resource "aws_lambda_function" "this" {
  filename         = data.archive_file.this.output_path
  function_name    = var.function_name
  role             = aws_iam_role.this.arn
  handler          = "lambda_function.lambda_handler"
  source_code_hash = data.archive_file.this.output_base64sha256
  timeout          = 30
  runtime          = "python3.8"
}
