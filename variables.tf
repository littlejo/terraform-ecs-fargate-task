variable region {
  default = "us-east-1"
}

variable ecs_cluster_name {
  default = "unzip-cluster"
}

variable container_image {
  default = "littlejo/unzip-s3:bash"
}

variable container_name {
  default = "unzip"
}

variable awslogs_group {
  default = "/ecs-cluster/services/unzip"
}

variable family {
  default = "unzip"
}

variable function_name {
  default = "create_zip"
}
