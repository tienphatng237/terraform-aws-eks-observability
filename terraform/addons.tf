# AWS EBS CSI Driver Addon (with IRSA)
# Get OIDC provider from the EKS cluster
data "aws_iam_openid_connect_provider" "oidc" {
  arn = module.eks.oidc_provider_arn
}

locals {
  oidc_hostpath = replace(data.aws_iam_openid_connect_provider.oidc.url, "https://", "")
}

# IAM Role for EBS CSI Controller ServiceAccount
resource "aws_iam_role" "ebs_csi_irsa_role" {
  name = "${var.project_name}-ebs-csi-irsa-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Federated = data.aws_iam_openid_connect_provider.oidc.arn
      },
      Action = "sts:AssumeRoleWithWebIdentity",
      Condition = {
        StringEquals = {
          "${local.oidc_hostpath}:aud" = "sts.amazonaws.com",
          "${local.oidc_hostpath}:sub" = "system:serviceaccount:kube-system:ebs-csi-controller-sa"
        }
      }
    }]
  })
}

# Attach AmazonEBSCSIDriverPolicy to the role
resource "aws_iam_role_policy_attachment" "ebs_csi_irsa_policy" {
  role       = aws_iam_role.ebs_csi_irsa_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}

# Create the EBS CSI Driver Addon and attach the IAM Role above
resource "aws_eks_addon" "ebs_csi" {
  cluster_name             = var.cluster_name
  addon_name               = "aws-ebs-csi-driver"
  service_account_role_arn = aws_iam_role.ebs_csi_irsa_role.arn

  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  depends_on = [
    module.eks,
    aws_iam_role_policy_attachment.ebs_csi_irsa_policy
  ]
}
