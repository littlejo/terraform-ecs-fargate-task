data "template_file" "this" {
  template = file("${path.module}/create_task.py.tpl")
  vars = {
    default_sg     = var.default_sg
    default_subnet = var.default_subnet
    family         = var.family
    container_name = var.container_name
  }
}

data "archive_file" "this" {
  type                    = "zip"
  source_content          = data.template_file.this.rendered
  source_content_filename = "lambda_function.py"
  output_path             = "${path.module}/lambda.zip"
}

resource "aws_lambda_function" "this" {
  filename         = data.archive_file.this.output_path
  function_name    = var.function_name
  role             = aws_iam_role.this.arn #see iam.tf
  handler          = "lambda_function.lambda_handler"
  source_code_hash = data.archive_file.this.output_base64sha256
  timeout          = 30
  runtime          = "python3.8"
}
