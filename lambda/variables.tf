variable function_name {
  type = string
  description = "name of lambda function"
}

variable family {
  type = string
  description = "family of task definition with revision: format: $family:$revision"
}

variable container_name {
  type = string
  description = "name of container you want to launch"
}

variable default_sg {
  type = string
  description = "id of security group you want to launch the container"
}

variable default_subnet {
  type = string
  description = "id of subnet you want to launch the container"
}
