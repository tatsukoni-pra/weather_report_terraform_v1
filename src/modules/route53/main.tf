resource "aws_route53_zone" "private" {
  name = "${var.service_name}.local"
  vpc {
    vpc_id = var.vpc_id
  }

  tags = {
    Name = "${var.service_name}.local"
  }
}
