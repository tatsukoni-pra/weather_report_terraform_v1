output "vpc_id" {
  value       = aws_vpc.service_vpc.id
  description = "VPC id"
}

output "cidr_block" {
  value       = aws_vpc.service_vpc.cidr_block
  description = "VPC cidr block"
}

output "public_subnet_1a_id" {
  value       = aws_subnet.public_1a.id
  description = "Public subnet 1a id"
}

output "public_subnet_1c_id" {
  value       = aws_subnet.public_1c.id
  description = "Public subnet 1c id"
}

output "private_subnet_1a_id" {
  value       = aws_subnet.private_1a.id
  description = "Private subnet 1a id"
}

output "private_subnet_1c_id" {
  value       = aws_subnet.private_1c.id
  description = "Private subnet 1c id"
}

output "public_route_table_id" {
  value       = aws_route_table.public.id
  description = "Public route table id"
}

output "private_route_table_id" {
  value       = aws_route_table.private.id
  description = "Private route table id"
}
