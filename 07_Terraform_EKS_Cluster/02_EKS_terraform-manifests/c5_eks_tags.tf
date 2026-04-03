# -------------------------------------------------------------------
# Public Subnet Tags for EKS Load Balancer Support
# -------------------------------------------------------------------

# This is required to tell EKS that these subnets should be used for load balancers
# (ELB) and are part of the EKS cluster. This allows EKS to automatically create
# and manage load balancers in these subnets when needed.

resource "aws_ec2_tag" "eks_subnet_tag_public_elb" {
  for_each    = toset(data.terraform_remote_state.vpc.outputs.public_subnet_ids)
  resource_id = each.value
  key         = "kubernetes.io/role/elb"
  value       = "1"
}


# This means multiple EKS clusters can share the same subnets, and EKS will know
# which subnets belong to which cluster based on the tags. The "shared" value
# indicates that the subnet is shared among multiple clusters. This is useful 
#in scenarios where you want to have multiple EKS clusters in the same VPC and
# want to use the same subnets for load balancers, but still want to keep track
# of which subnets are associated with which clusters:


resource "aws_ec2_tag" "eks_subnet_tag_public_cluster" {
  for_each    = toset(data.terraform_remote_state.vpc.outputs.public_subnet_ids)
  resource_id = each.value
  key         = "kubernetes.io/cluster/${local.eks_cluster_name}"
  value       = "shared"
}

# -------------------------------------------------------------------
# Private Subnet Tags for EKS Internal LoadBalancer Support
# -------------------------------------------------------------------


# Same as above just for internal load balancers. This is required to tell EKS
# that these subnets should be used for internal load balancers and are part
# of the EKS cluster. This allows EKS to automatically create and manage internal load balancers
# in these subnets when needed:



resource "aws_ec2_tag" "eks_subnet_tag_private_elb" {
  for_each    = toset(data.terraform_remote_state.vpc.outputs.private_subnet_ids)
  resource_id = each.value
  key         = "kubernetes.io/role/internal-elb"
  value       = "1"
}

resource "aws_ec2_tag" "eks_subnet_tag_private_cluster" {
  for_each    = toset(data.terraform_remote_state.vpc.outputs.private_subnet_ids)
  resource_id = each.value
  key         = "kubernetes.io/cluster/${local.eks_cluster_name}"
  value       = "shared"
}
