# EKS Pod Identity Association
# This links the IAM role created for the AWS Load Balancer
# Controller to the Kubernetes service account created when we install the lbc
# helm chart below in file c15-01-lbc-helm-installation.tf. 
# This allows the lbc to assume the IAM role:


resource "aws_eks_pod_identity_association" "lbc" {
  cluster_name    = aws_eks_cluster.main.name
  namespace       = "kube-system"
  service_account = "aws-load-balancer-controller"
  role_arn        = aws_iam_role.lbc_iam_role.arn
}

# Output: LBC Pod Identity Association ARN
output "lbc_pod_identity_association_arn" {
  description = "AWS Load Balancer Controller Pod Identity Association ARN"
  value       = aws_eks_pod_identity_association.lbc.association_arn
}
