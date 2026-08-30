# Datasource: IAM Policy Document 
# this Terraform data source builds an IAM trust policy that allows
# EKS Pod Identity to assume IAM roles on behalf of Kubernetes pods.

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"                  # Trusting Service not a user or role !
      identifiers = ["pods.eks.amazonaws.com"] # allow pods to assume this role
    }

    actions = [
      "sts:AssumeRole",
      "sts:TagSession"
    ]
  }
}
