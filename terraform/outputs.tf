output "vpc_id" {
  value = module.network.vpc_id
}

output "public_subnet_ids" {
  value = module.network.public_subnet_ids
}

# Chỉ còn 1 loại private subnet
output "private_subnet_ids" {
  value = module.network.private_subnet_ids
}

output "nat_gateway_ids" {
  value = module.network.nat_gateway_ids
}

output "internet_gateway_id" {
  value = module.network.igw_id
}

output "eks_cluster_name" {
  value = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "eks_oidc_provider_arn" {
  value = module.eks.oidc_provider_arn
}

output "security_groups" {
  value = {
    public_gateway_sg_id = module.security_groups.public_gateway_sg_id
    app_node_sg_id       = module.security_groups.app_node_sg_id
    monitoring_sg_id     = module.security_groups.monitoring_sg_id
    db_sg_id             = module.security_groups.db_sg_id
  }
}
