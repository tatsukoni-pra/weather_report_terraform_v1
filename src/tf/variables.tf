variable "service_name" {
  default = "tatsukoni-demo"
}

variable "account_id" {
  default = "0000000000"
}

variable "awesome_domain" {
  default = "awsometatsukoni.com"
}

data "aws_ssm_parameter" "awesome_certificate_arn" {
  name = "/acm/awesome_certificate_arn"
}

data "aws_ssm_parameter" "awesome_route53_zone_id" {
  name = "/route53/awesome_route53_zone_id"
}
