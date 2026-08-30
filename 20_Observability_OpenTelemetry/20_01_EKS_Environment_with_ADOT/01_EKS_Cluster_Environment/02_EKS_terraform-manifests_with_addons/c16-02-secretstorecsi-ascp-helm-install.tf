# Install AWS Secrets and Configuration Provider (ASCP)
# ASCP is the AWS-specific plugin. It knows how to authenticate to
# AWS and fetch values from AWS Secrets Manager or Parameter Store.

resource "helm_release" "aws_secrets_provider" {
  depends_on = [
    aws_eks_addon.podidentity,
    aws_eks_node_group.private_nodes,
    helm_release.secrets_store_csi_driver
  ]


  name       = "secrets-provider-aws"
  repository = "https://aws.github.io/secrets-store-csi-driver-provider-aws"
  chart      = "secrets-store-csi-driver-provider-aws"
  namespace  = "kube-system"

  # Disable re-installation of CSI driver (already installed separately)
  set = [
    {
      # Do not install the Secrets Store CSI Driver again, since we already installed it above in this file
      name  = "secrets-store-csi-driver.install"
      value = "false"
    },
    # Add toleration. This allows the ASCP pods to be scheduled on any node !
    {
      name  = "tolerations[0].operator"
      value = "Exists"
    }
  ]

  # Wait for all pods to become ready
  wait            = true
  timeout         = 600
  cleanup_on_fail = true
}

################################################################################
# Outputs
################################################################################

output "helm_aws_secrets_provider_metadata" {
  description = "Metadata for the AWS Secrets and Configuration Provider Helm release"
  value       = helm_release.aws_secrets_provider.metadata
}
