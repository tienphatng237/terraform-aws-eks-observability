# Output ARNs to bind into ServiceAccounts later
output "irsa_roles" {
  value = {
    for k, r in aws_iam_role.sa : k => r.arn
  }
}