# Resource: EKS Pod Identity Association for EBS CSI Driver
resource "aws_eks_pod_identity_association" "ebs_csi" {
  cluster_name = aws_eks_cluster.main.name
  namespace    = "kube-system"

  # This service account is created by the EBS CSI Driver addon and is 
  # used to associate the IAM Role with the EBS CSI Driver pods.
  service_account = "ebs-csi-controller-sa"
  role_arn        = aws_iam_role.ebs_csi_iam_role.arn
}

# Output: EBS CSI Pod Identity Association ARN
output "ebs_csi_pod_identity_association_arn" {
  description = "EBS CSI Driver Pod Identity Association ARN"
  value       = aws_eks_pod_identity_association.ebs_csi.association_arn
}
