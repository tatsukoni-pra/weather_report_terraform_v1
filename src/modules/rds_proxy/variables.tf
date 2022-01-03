variable "service_name" {
  description = "Service Name"
}

variable "target_vpc" {
  description = "RDS VPC"
}

variable "private_sub" {
  description = "RDS subnets"
}

variable "vpc_cidr_block" {
  description = "RDS VPC cidr block"
}

variable "cluster_id" {
  description = "Cluster Id"
}

locals {
  engine_family = "MYSQL"
}

data "aws_ssm_parameter" "db_username" {
  name = "/lambda/DB_USERNAME"
}

data "aws_ssm_parameter" "db_password" {
  name = "/lambda/DB_PASSWORD"
}

data "aws_ssm_parameter" "db_host" {
  name = "/rds/DB_HOST"
}
