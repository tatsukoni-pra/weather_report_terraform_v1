resource "aws_vpc_endpoint" "ssm" {
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.ap-northeast-1.ssm"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids          = var.private_sub
  security_group_ids = [
    aws_security_group.endpoint_sg.id
  ]

  tags = {
    Name = "${var.service_name}-ssm-endpoint"
  }
}

resource "aws_vpc_endpoint" "ssmmessages" {
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.ap-northeast-1.ssmmessages"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids          = var.private_sub
  security_group_ids = [
    aws_security_group.endpoint_sg.id
  ]

  tags = {
    Name = "${var.service_name}-ssmmessages-endpoint"
  }
}

resource "aws_vpc_endpoint" "ecr_api" {
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.ap-northeast-1.ecr.api"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids          = var.private_sub
  security_group_ids = [
    aws_security_group.endpoint_sg.id
  ]

  tags = {
    Name = "${var.service_name}-ecr_api-endpoint"
  }
}

resource "aws_vpc_endpoint" "ecr_dkr" {
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.ap-northeast-1.ecr.dkr"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids          = var.private_sub
  security_group_ids = [
    aws_security_group.endpoint_sg.id
  ]

  tags = {
    Name = "${var.service_name}-ecr_dkr-endpoint"
  }
}

resource "aws_vpc_endpoint" "secretsmanager" {
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.ap-northeast-1.secretsmanager"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids          = var.private_sub
  security_group_ids = [
    aws_security_group.endpoint_sg.id
  ]

  tags = {
    Name = "${var.service_name}-secretsmanager-endpoint"
  }
}

###############################################
# Security Group
###############################################
resource "aws_security_group" "endpoint_sg" {
  vpc_id      = var.vpc_id
  name        = "${var.service_name}-endpoints-sg"
  description = "${var.service_name}-endpoints-sg"

  tags = {
    Name = "${var.service_name}-endpoints-sg"
  }
}

resource "aws_security_group_rule" "endpoint_sg_ingress" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.endpoint_sg.id
  depends_on        = [aws_security_group.endpoint_sg]
  cidr_blocks       = [var.vpc_cidr_block]
}

resource "aws_security_group_rule" "endpoint_sg_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "all"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.endpoint_sg.id
  depends_on        = [aws_security_group.endpoint_sg]
}
