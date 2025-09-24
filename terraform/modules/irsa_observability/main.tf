data "aws_iam_openid_connect_provider" "oidc" {
  arn = var.oidc_provider_arn
}

locals {
  issuer_hostpath = replace(var.cluster_openid_issuer, "https://", "")
}

# Helper to build trust policy for SA
locals {
  sa_map = {
    "prometheus" = "prometheus"
    "loki"       = "loki"
    "tempo"      = "tempo"
    "icinga"     = "icinga"
  }
}

# Create roles
resource "aws_iam_role" "sa" {
  for_each = local.sa_map
  name = "${var.project_name}-irsa-${each.key}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRoleWithWebIdentity"
      Effect = "Allow"
      Principal = {
        Federated = data.aws_iam_openid_connect_provider.oidc.arn
      }
      Condition = {
        StringEquals = {
          "${local.issuer_hostpath}:sub" = "system:serviceaccount:${var.namespace}:${each.value}"
          "${local.issuer_hostpath}:aud" = "sts.amazonaws.com"
        }
      }
    }]
  })
}

# Optional S3 access for Loki
resource "aws_iam_policy" "loki_s3" {
  count = var.loki_s3_bucket != "" ? 1 : 0
  name  = "${var.project_name}-loki-s3"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow",
      Action = ["s3:PutObject","s3:AbortMultipartUpload","s3:ListBucket","s3:GetObject","s3:DeleteObject"],
      Resource = [
        "arn:aws:s3:::${var.loki_s3_bucket}",
        "arn:aws:s3:::${var.loki_s3_bucket}/*"
      ]
    }]
  })
}

resource "aws_iam_role_policy_attachment" "loki_attach" {
  count      = var.loki_s3_bucket != "" ? 1 : 0
  role       = aws_iam_role.sa["loki"].name
  policy_arn = aws_iam_policy.loki_s3[0].arn
}

# Optional S3 access for Tempo
resource "aws_iam_policy" "tempo_s3" {
  count = var.tempo_s3_bucket != "" ? 1 : 0
  name  = "${var.project_name}-tempo-s3"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow",
      Action = ["s3:PutObject","s3:AbortMultipartUpload","s3:ListBucket","s3:GetObject","s3:DeleteObject"],
      Resource = [
        "arn:aws:s3:::${var.tempo_s3_bucket}",
        "arn:aws:s3:::${var.tempo_s3_bucket}/*"
      ]
    }]
  })
}

resource "aws_iam_role_policy_attachment" "tempo_attach" {
  count      = var.tempo_s3_bucket != "" ? 1 : 0
  role       = aws_iam_role.sa["tempo"].name
  policy_arn = aws_iam_policy.tempo_s3[0].arn
}

