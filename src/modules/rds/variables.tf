variable "service_name" {
  description = "Service Name"
}

variable "database_name" {
  description = "Database Name"
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

locals {
  # common
  engine             = "aurora-mysql"
  engine_version     = "5.7.mysql_aurora.2.10.0"
  instance_class     = "db.t2.small"
  availability_zones = ["ap-northeast-1a", "ap-northeast-1c"]
  port               = 3306

  # cluster
  backup_retention_period      = 1
  preferred_maintenance_window = "Sun:19:00-Sun:19:30"
  cluster_parameter_group = {
    name   = "${var.service_name}-dbcluster-parameter"
    family = "aurora-mysql5.7"
  }

  # db instance
  cluster_instance_count = 1
  db_parameter_group = {
    name   = "${var.service_name}-db-parameter"
    family = "aurora-mysql5.7"
  }
}

data "aws_ssm_parameter" "db_master_username" {
  name = "/rds/master_username"
}

data "aws_ssm_parameter" "db_master_password" {
  name = "/rds/master_password"
}
