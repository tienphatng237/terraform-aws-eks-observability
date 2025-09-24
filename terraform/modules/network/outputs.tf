output "vpc_id" {
  value = aws_vpc.this.id
}

output "public_subnet_ids" {
  value = [for s in aws_subnet.public : s.id]
}

output "private_subnet_ids" {
  value = [for s in aws_subnet.private : s.id]
}

output "igw_id" {
  value = aws_internet_gateway.this.id
}

output "nat_gateway_ids" {
  value = [for n in aws_nat_gateway.this : n.id]
}
