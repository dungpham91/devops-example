output "aws_subnets_private" {
  description = "A list of the private subnets"
  value       = aws_subnet.private_subnet.*.id
}

output "aws_subnets_public" {
  description = "A list of the public subnets"
  value       = aws_subnet.public_subnet.*.id
}

output "cidr_block" {
  description = "The CDIR block used for the VPC"
  value       = aws_vpc.vpc.cidr_block
}

output "private_route_table" {
  description = "The id of the private route table"
  value       = aws_route_table.private_route_table.id
}

output "public_route_table" {
  description = "The id of the public route table"
  value       = aws_route_table.public_route_table.id
}

output "vpc_id" {
  description = "The id of the VPC"
  value       = aws_vpc.vpc.id
}
