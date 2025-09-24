module "network" {
  source               = "./modules/network"
  project_name         = var.project_name
  region               = var.region
  azs                  = var.azs
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  create_second_nat    = var.create_second_nat
}

module "security_groups" {
  source               = "./modules/security_groups"
  vpc_id               = module.network.vpc_id
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  project_name         = var.project_name
}

module "eks" {
  source            = "./modules/eks"
  project_name      = var.project_name
  cluster_version   = var.eks_cluster_version
  vpc_id            = module.network.vpc_id
  private_subnet_ids = module.network.private_subnet_ids

  node_instance_types = var.node_instance_types
  node_desired_size   = var.node_desired_size
  node_min_size       = var.node_min_size
  node_max_size       = var.node_max_size
  enable_karpenter    = var.enable_karpenter
}

# IRSA roles for Prometheus/Loki/Tempo/Icinga
module "irsa_observability" {
  source                = "./modules/irsa_observability"
  project_name          = var.project_name
  oidc_provider_arn     = module.eks.oidc_provider_arn
  cluster_openid_issuer = data.aws_eks_cluster.this.identity[0].oidc[0].issuer  # use data source
  namespace             = var.observability_namespace
  loki_s3_bucket        = var.loki_s3_bucket
  tempo_s3_bucket       = var.tempo_s3_bucket
}

# AWS Load Balancer Controller (Helm) + IRSA
module "alb_controller" {
  source            = "./modules/alb_controller"
  project_name      = var.project_name
  region            = var.region
  cluster_name      = module.eks.cluster_name
  vpc_id            = module.network.vpc_id
  oidc_provider_arn = module.eks.oidc_provider_arn
  namespace         = "kube-system"
}
