output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnet_ids" {
  value = aws_subnet.public[*].id
}

output "internet_gateway_id" {
  value = aws_internet_gateway.igw.id
}

output "public_route_table_id" {
  value = aws_route_table.public.id
}

output "nat_gateway_id" {
  value = aws_nat_gateway.nat.id
}

output "private_subnet_ids" {
  value = aws_subnet.private[*].id
}
