variable "service_name" {
  description = "Service Name"
  default     = "ec2-line-notify"
}

variable "vpc_id" {
  description = "VPC Id"
}

variable "vpc_cidr_block" {
  description = "VPC Cidr block"
}

variable "public_sub_id" {
  description = "Public Subnet Id"
}

variable "public_sub_1c_id" {
  description = "Public Subnet 1c Id"
}

variable "certificate_arn" {
  description = "ACM Certificate Arn For HTTPS Access"
}

variable "zone_id" {
  description = "Route53 Zone ID"
}

variable "domain" {
  description = "Domain"
}

locals {
  ec2_instance_values = {
    ami           = "ami-06ce6680729711877"
    instance_type = "t2.micro"
  }
}
