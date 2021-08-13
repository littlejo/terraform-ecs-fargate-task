module "unzip" {
  source               = "../../"
  ecs_cluster_name     = "unzip-cluster"
  container_image      = "littlejo/unzip-s3:bash"
  container_name       = "unzip"
  awslogs_group        = "/ecs-cluster/services/unzip"
  family               = "unzip"
  lambda_function_name = "create_zip"
}
