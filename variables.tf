variable "ecs_cluster_name" {
  type        = string
  description = "Name of ecs cluster where you launch ecs task"
}

variable "container_image" {
  type        = string
  description = "Name of docker hub repo"
}

variable "container_name" {
  type        = string
  description = "Name of container of ecs task"
}

variable "awslogs_group" {
  type        = string
  description = "Logs group name of task"
}

variable "family" {
  type        = string
  description = "Family of task definition"
}

variable "lambda_function_name" {
  type        = string
  description = "Name of lambda function"
}
