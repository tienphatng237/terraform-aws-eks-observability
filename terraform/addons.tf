# AWS EBS CSI Addon
resource "aws_eks_addon" "ebs_csi" {
  cluster_name                = var.cluster_name
  addon_name                  = "aws-ebs-csi-driver"
  addon_version               = "v1.29.0-eksbuild.1"
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  depends_on = [ module.eks ]
}

# IAM policy for Pod Identity
resource "aws_iam_role" "ebs_csi_pod_role" {
  name = "${var.cluster_name}-ebs-csi-pod-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
        Action = [ "sts:AssumeRole", "sts:TagSession" ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ebs_csi_policy" {
  role       = aws_iam_role.ebs_csi_pod_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}

# Link role with SA ebs-csi-controller-sa
resource "aws_eks_pod_identity_association" "ebs_csi_assoc" {
  cluster_name    = var.cluster_name
  namespace       = "kube-system"
  service_account = "ebs-csi-controller-sa"
  role_arn        = aws_iam_role.ebs_csi_pod_role.arn

  depends_on = [ aws_eks_addon.ebs_csi ]
}