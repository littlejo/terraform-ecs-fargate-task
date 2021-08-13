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
      "awslogs-region"        = data.aws_region.current.name,
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

resource "aws_cloudwatch_log_group" "this" {
  name = var.awslogs_group
}

resource "aws_ecs_cluster" "cluster" {
  name = var.ecs_cluster_name
}

module "lambda" {
  source         = "./lambda"
  family         = "${var.family}:${aws_ecs_task_definition.this.revision}"
  container_name = var.container_name
  function_name  = var.lambda_function_name
  default_sg     = data.aws_security_groups.main.ids[0]
  default_subnet = tolist(data.aws_subnet_ids.main.ids)[0]
  cluster        = var.ecs_cluster_name
}
