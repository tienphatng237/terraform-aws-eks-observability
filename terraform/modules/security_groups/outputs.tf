output "public_gateway_sg_id" {
  value = aws_security_group.public_gateway.id
}

output "app_node_sg_id" {
  value = aws_security_group.app_nodes.id
}

output "monitoring_sg_id" {
  value = aws_security_group.monitoring.id
}

output "db_sg_id" {
  value = aws_security_group.db.id
}