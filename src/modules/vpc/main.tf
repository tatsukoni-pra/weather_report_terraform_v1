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
