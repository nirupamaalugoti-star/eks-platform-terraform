variable "cluster_name"       {}
variable "oidc_provider_arn"  {}
variable "oidc_provider_url"  {}

# Example IRSA role for a service account that needs S3/CloudWatch access.
resource "aws_iam_role" "app_service_account" {
  name = "${var.cluster_name}-app-sa"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = { Federated = var.oidc_provider_arn }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "${replace(var.oidc_provider_url, "https://", "")}:sub" = "system:serviceaccount:default:app-sa"
        }
      }
    }]
  })
}

output "role_arn" { value = aws_iam_role.app_service_account.arn }
