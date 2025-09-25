# Project & region
project_name = "eks-obser"
region       = "ap-southeast-1"

azs = [
  "ap-southeast-1a",
  "ap-southeast-1b",
  "ap-southeast-1c"
]

# VPC & Subnets
vpc_cidr             = "10.0.0.0/16"
public_subnet_cidrs  = [
    "10.0.1.0/24",  
    "10.0.2.0/24",  
    "10.0.3.0/24"
]

private_subnet_cidrs = [
    "10.0.11.0/24", 
    "10.0.12.0/24", 
    "10.0.13.0/24"]

create_second_nat = true

# EKS cluster config
eks_cluster_version = "1.30"
node_instance_types = ["t3.large"]
node_desired_size   = 2
node_min_size       = 2
node_max_size       = 4
enable_karpenter    = false

cluster_name = "eks-obser-cluster"
