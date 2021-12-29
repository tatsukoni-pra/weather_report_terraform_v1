###############################################
# Vpc Resource
###############################################
resource "aws_vpc" "service_vpc" {
  cidr_block           = local.vpc.cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.service_name}-vpc"
  }
}

resource "aws_subnet" "public_1a" {
  vpc_id                  = aws_vpc.service_vpc.id
  cidr_block              = local.public_subnet_1a.cidr_block
  availability_zone       = local.public_subnet_1a.az
  map_public_ip_on_launch = true
  depends_on              = [aws_vpc.service_vpc]

  tags = {
    Name = "${var.service_name}-subnet-public-1a"
  }
}

resource "aws_subnet" "public_1c" {
  vpc_id                  = aws_vpc.service_vpc.id
  cidr_block              = local.public_subnet_1c.cidr_block
  availability_zone       = local.public_subnet_1c.az
  map_public_ip_on_launch = true
  depends_on              = [aws_vpc.service_vpc]

  tags = {
    Name = "${var.service_name}-subnet-public-1c"
  }
}

resource "aws_subnet" "private_1a" {
  vpc_id                  = aws_vpc.service_vpc.id
  cidr_block              = local.private_subnet_1a.cidr_block
  availability_zone       = local.private_subnet_1a.az
  map_public_ip_on_launch = false
  depends_on              = [aws_vpc.service_vpc]

  tags = {
    Name = "${var.service_name}-subnet-private-1a"
  }
}

resource "aws_subnet" "private_1c" {
  vpc_id                  = aws_vpc.service_vpc.id
  cidr_block              = local.private_subnet_1c.cidr_block
  availability_zone       = local.private_subnet_1c.az
  map_public_ip_on_launch = false
  depends_on              = [aws_vpc.service_vpc]

  tags = {
    Name = "${var.service_name}-subnet-private-1c"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.service_vpc.id

  tags = {
    Name = "${var.service_name}-igw"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.service_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${var.service_name}-public-table"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.service_vpc.id

  tags = {
    Name = "${var.service_name}-private-table"
  }
}

resource "aws_route_table_association" "public_1a" {
  route_table_id = aws_route_table.public.id
  subnet_id      = aws_subnet.public_1a.id
}

resource "aws_route_table_association" "public_1c" {
  route_table_id = aws_route_table.public.id
  subnet_id      = aws_subnet.public_1c.id
}

resource "aws_route_table_association" "private_1a" {
  route_table_id = aws_route_table.private.id
  subnet_id      = aws_subnet.private_1a.id
}

resource "aws_route_table_association" "private_1c" {
  route_table_id = aws_route_table.private.id
  subnet_id      = aws_subnet.private_1c.id
}

###############################################
# Vpc endpoint
###############################################
resource "aws_vpc_endpoint" "ssm" {
  depends_on          = [aws_route_table.private]
  vpc_id              = aws_vpc.service_vpc.id
  service_name        = "com.amazonaws.ap-northeast-1.ssm"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids = [
    aws_subnet.private_1a.id,
    aws_subnet.private_1c.id
  ]
  security_group_ids = [
    aws_security_group.endpoint_sg.id
  ]

  tags = {
    Name = "${var.service_name}-ssm-endpoint"
  }
}

resource "aws_vpc_endpoint" "ssmmessages" {
  depends_on          = [aws_route_table.private]
  vpc_id              = aws_vpc.service_vpc.id
  service_name        = "com.amazonaws.ap-northeast-1.ssmmessages"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids = [
    aws_subnet.private_1a.id,
    aws_subnet.private_1c.id
  ]
  security_group_ids = [
    aws_security_group.endpoint_sg.id
  ]

  tags = {
    Name = "${var.service_name}-ssmmessages-endpoint"
  }
}

resource "aws_vpc_endpoint" "ecr_api" {
  depends_on          = [aws_route_table.private]
  vpc_id              = aws_vpc.service_vpc.id
  service_name        = "com.amazonaws.ap-northeast-1.ecr.api"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids = [
    aws_subnet.private_1a.id,
    aws_subnet.private_1c.id
  ]
  security_group_ids = [
    aws_security_group.endpoint_sg.id
  ]

  tags = {
    Name = "${var.service_name}-ecr_api-endpoint"
  }
}

resource "aws_vpc_endpoint" "ecr_dkr" {
  depends_on          = [aws_route_table.private]
  vpc_id              = aws_vpc.service_vpc.id
  service_name        = "com.amazonaws.ap-northeast-1.ecr.dkr"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids = [
    aws_subnet.private_1a.id,
    aws_subnet.private_1c.id
  ]
  security_group_ids = [
    aws_security_group.endpoint_sg.id
  ]

  tags = {
    Name = "${var.service_name}-ecr_dkr-endpoint"
  }
}

###############################################
# Security Group
###############################################
resource "aws_security_group" "endpoint_sg" {
  vpc_id      = aws_vpc.service_vpc.id
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
  cidr_blocks       = [local.vpc.cidr_block]
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
