output "aws_subnet_ids" {
  value = data.aws_subnet_ids.main.ids
}

output "aws_security_groups" {
  value = data.aws_security_groups.main.ids
}
