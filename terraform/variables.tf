variable "project_name" {
  description = "A short name used for tagging and resource naming."
  type        = string
  default     = "eks-obser"
}

variable "region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "ap-southeast-1"
}

variable "azs" {
  description = "List of two AZs to use"
  type        = list(string)
  default     = ["ap-southeast-1a", "ap-southeast-1b"]
}

variable "vpc_cidr" {
  description = "CIDR for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

# Public subnets
variable "public_subnet_cidrs" {
  description = "CIDRs for public subnets (2)"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

# Private app subnets (EKS nodes)
variable "private_subnet_cidrs" {
  type = list(string)
}


variable "create_second_nat" {
  description = "Whether to create one NAT per AZ (true) or a single NAT in the first AZ (false)"
  type        = bool
  default     = false
}

# EKS variables
variable "eks_cluster_version" {
  description = "EKS Kubernetes version"
  type        = string
  default     = "1.30"
}

variable "node_instance_types" {
  description = "EC2 instance types for managed node group"
  type        = list(string)
  default     = ["t3.large"]
}

variable "node_desired_size" {
  type        = number
  default     = 2
}

variable "node_min_size" {
  type        = number
  default     = 2
}

variable "node_max_size" {
  type        = number
  default     = 5
}

variable "enable_karpenter" {
  description = "If true, add IAM permissions that are friendly with Karpenter. (Optional, not installing Karpenter here)"
  type        = bool
  default     = false
}


variable "domain_name" {
  description = "Root domain (e.g., example.com). Required if create_hosted_zone = true or if using ACM."
  type        = string
  default     = ""
}

variable "subject_alternative_names" {
  description = "Subject alternative names for ACM cert"
  type        = list(string)
  default     = []
}


# --- IRSA S3 buckets (optional) ---
variable "loki_s3_bucket" {
  description = "S3 bucket name for Loki (optional)"
  type        = string
  default     = ""
}

variable "tempo_s3_bucket" {
  description = "S3 bucket name for Tempo (optional)"
  type        = string
  default     = ""
}

variable "observability_namespace" {
  description = "Kubernetes namespace for observability tools"
  type        = string
  default     = "observability"
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}
