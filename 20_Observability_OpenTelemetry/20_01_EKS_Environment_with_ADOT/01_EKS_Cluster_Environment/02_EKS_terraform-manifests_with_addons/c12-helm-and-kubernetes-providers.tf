# Datasource: EKS Cluster Auth 
# Summary: this Terraform data source generates a temporary authentication
# token that lets Terraform connect to the EKS cluster’s Kubernetes API.
data "aws_eks_cluster_auth" "cluster" {
  name = aws_eks_cluster.main.id
}

# HELM Provider
# Used later to install Helm charts into the EKS cluster 
#(e.g. Load Balancer Controller and ADOT Collector)

provider "helm" {
  kubernetes = {
    host                   = aws_eks_cluster.main.endpoint
    cluster_ca_certificate = base64decode(aws_eks_cluster.main.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.cluster.token
  }
}

# Terraform Kubernetes Provider (Not used in this demo, but included for reference)
provider "kubernetes" {
  host                   = aws_eks_cluster.main.endpoint
  cluster_ca_certificate = base64decode(aws_eks_cluster.main.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}


