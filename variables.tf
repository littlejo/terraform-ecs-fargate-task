variable "ecs_cluster_name" {
  default = "unzip-cluster"
  type = string
  description = "Name of ecs cluster where you launch ecs task"
}

variable "container_image" {
  default = "littlejo/unzip-s3:bash"
  type = string
  description = "Name of docker hub repo"
}

variable "container_name" {
  default = "unzip"
  type = string
  description = "Name of container of ecs task"
}

variable "awslogs_group" {
  default = "/ecs-cluster/services/unzip"
  type = string
  description = "Logs group name of task"
}

variable "family" {
  default = "unzip"
  type = string
  description = "Family of task definition"
}

variable "lambda_function_name" {
  default = "create_zip"
  type = string
  description = "Name of lambda function"
}
