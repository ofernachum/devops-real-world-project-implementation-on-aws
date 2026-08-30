
# This allows the Karpenter nodes to be recognized by the EKS cluster and to
# have the necessary permissions to interact with AWS services. 
#The `aws_eks_access_entry` resource is used to grant access to the Karpenter node
# IAM role for the EKS cluster.

resource "aws_eks_access_entry" "karpenter_node_access" {
  depends_on    = [data.terraform_remote_state.eks]
  cluster_name  = data.terraform_remote_state.eks.outputs.eks_cluster_name
  principal_arn = aws_iam_role.karpenter_node.arn
  type          = "EC2_LINUX"
}
