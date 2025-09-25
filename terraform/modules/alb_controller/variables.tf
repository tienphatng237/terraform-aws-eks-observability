variable "project_name" {
  type        = string
  description = "Project name used for tagging and naming resources"
}

variable "region" {
  type        = string
  description = "AWS region where the resources will be created"
}

variable "cluster_name" {
  type        = string
  description = "EKS cluster name"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID for the EKS cluster"
}

variable "oidc_provider_arn" {
  type        = string
  description = "OIDC provider ARN from the EKS cluster"
}

variable "namespace" {
  type        = string
  default     = "kube-system"
  description = "Namespace for AWS Load Balancer Controller"
}
