# IAM Policy: Allow access to all retailstore-db-secrets
# This policy is attached to the IAM role associated with retail store
# application service accounts mapped to pod identity to access secrets 
# in AWS Secrets Manager.

resource "aws_iam_policy" "retailstore_db_secret_policy" {
  name        = "${local.name}-retailstore-db-secret-policy"
  description = "Allows access to retailstore-db-secret* in AWS Secrets Manager"
  path        = "/"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = "arn:aws:secretsmanager:${var.aws_region}:${data.aws_caller_identity.current.account_id}:secret:retailstore-db-secret*"
      }
    ]
  })
}

# Outputs
output "retailstore_db_secret_policy_arn" {
  description = "IAM Policy ARN for retailstore-db-secret access"
  value       = aws_iam_policy.retailstore_db_secret_policy.arn
}
