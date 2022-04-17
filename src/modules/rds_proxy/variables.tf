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

variable "private_zone_id" {
  description = "Route53 Private Host Zone Id"
}

locals {
  engine_family                = "MYSQL"
  idle_client_timeout          = 1800
  connection_borrow_timeout    = 120
  max_connections_percent      = 50
  max_idle_connections_percent = 10
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
