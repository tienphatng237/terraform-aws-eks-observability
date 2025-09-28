terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.50"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.13"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.32"
    }
  }
}

# AWS Load Balancer Controller (ALB)

# Lấy OIDC provider từ EKS module
data "aws_iam_openid_connect_provider" "oidc" {
  arn = var.oidc_provider_arn
}

# IAM Policy cho ALB Controller (sử dụng file JSON chính thức của AWS)
resource "aws_iam_policy" "alb_controller" {
  name        = "${var.project_name}-AWSLoadBalancerControllerIAMPolicy"
  description = "Policy for AWS Load Balancer Controller"
  policy      = file("${path.module}/iam_policy.json")
}

# Extract hostpath từ OIDC URL (bỏ https://)
locals {
  issuer_hostpath = replace(data.aws_iam_openid_connect_provider.oidc.url, "https://", "")
}

# IAM Role cho ServiceAccount (IRSA)
resource "aws_iam_role" "alb_sa" {
  name = "${var.project_name}-alb-controller"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Action = "sts:AssumeRoleWithWebIdentity",
      Principal = {
        Federated = data.aws_iam_openid_connect_provider.oidc.arn
      },
      Condition = {
        StringEquals = {
          "${local.issuer_hostpath}:aud" = "sts.amazonaws.com",
          "${local.issuer_hostpath}:sub" = "system:serviceaccount:${var.namespace}:aws-load-balancer-controller"
        }
      }
    }]
  })
}

# Gắn IAM Policy vào Role
resource "aws_iam_role_policy_attachment" "alb_attach" {
  role       = aws_iam_role.alb_sa.name
  policy_arn = aws_iam_policy.alb_controller.arn
}

# ServiceAccount annotated với IAM Role (IRSA)
resource "kubernetes_service_account" "sa" {
  metadata {
    name      = "aws-load-balancer-controller"
    namespace = var.namespace
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.alb_sa.arn
    }
    labels = {
      "app.kubernetes.io/name" = "aws-load-balancer-controller"
    }
  }
  automount_service_account_token = true
}

# Helm release cho AWS Load Balancer Controller
resource "helm_release" "alb" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = var.namespace
  version    = "1.8.1"

  values = [yamlencode({
    clusterName = var.cluster_name
    region      = var.region
    vpcId       = var.vpc_id
    serviceAccount = {
      create = false
      name   = kubernetes_service_account.sa.metadata[0].name
    }
    defaultTags = {
      Project = var.project_name
    }
  })]

  depends_on = [
    kubernetes_service_account.sa,
    aws_iam_role_policy_attachment.alb_attach
  ]
}
