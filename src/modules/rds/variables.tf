variable "service_name" {
  description = "Service Name"
}

variable "subnet_group" {}

variable "db_availability_zones" {}
variable "cluster_parameter_group" {}
variable "cluster_parameter_family" {}
variable "database_name" {}
variable "schedule" {}
variable "parameter_family" {}
variable "db_option_group" {}
variable "target_vpc" {}
variable "private_sub" {}
variable "vpc_cidr_block" {}
variable "internal_domain" {}

locals {
  # common
  engine = "aurora-mysql"
  engine_version = "5.7.mysql_aurora.2.10.0"
  instance_class = "db.t2.small"
  availability_zones = ["ap-northeast-1a", "ap-northeast-1c"]
  port = 3306

  # cluster
  backup_retention_period = 1
  preferred_maintenance_window = "Sun:19:00-Sun:19:30"

  # db instance
  cluster_instance_count = 1
}

data "aws_ssm_parameter" "db_master_username" {
  name = "/rds/master_username"
}

data "aws_ssm_parameter" "db_master_password" {
  name = "/rds/master_password"
}
