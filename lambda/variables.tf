variable "function_name" {
  type        = string
  description = "name of lambda function"
}

variable "family" {
  type        = string
  description = "family of task definition with revision: format: $family:$revision"
}

variable "container_name" {
  type        = string
  description = "name of container you want to launch"
}

variable "sg" {
  type        = string
  description = "ids of security groups you want to launch the container (separated by comma)"
}

variable "subnets" {
  type        = string
  description = "ids of subnets you want to launch the container (separated by comma)"
}

variable "cluster" {
  type        = string
  description = "cluster name where you want to launch ecs task"
}
