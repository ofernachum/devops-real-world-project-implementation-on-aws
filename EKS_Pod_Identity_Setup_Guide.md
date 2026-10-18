# EKS Pod Identity Setup Guide

This guide explains the high-level steps required to prepare EKS Pod Identity for a future Kubernetes Deployment that needs access to these AWS services:

- Amazon S3
- Amazon SQS
- AWS Secrets Manager
- AWS Systems Manager Parameter Store

The goal of this guide is only to prepare the Pod Identity association. The actual application Deployment can be created later.

## Big Picture

EKS Pod Identity connects a Kubernetes ServiceAccount to an AWS IAM role.

When a pod uses that ServiceAccount, AWS allows the pod to use the IAM role permissions without storing AWS access keys in Kubernetes.

```text
Future Pod
  |
  | uses serviceAccountName
  v
Kubernetes ServiceAccount
  |
  | mapped by EKS Pod Identity Association
  v
AWS IAM Role
  |
  | grants access to
  v
S3 + SQS + Secrets Manager + Parameter Store
```

## 1. Cluster-Level Preparation

At the EKS cluster level, prepare the following:

1. Make sure the EKS cluster supports EKS Pod Identity.
2. Install the EKS Pod Identity Agent add-on.
3. Make sure worker nodes can run the Pod Identity Agent DaemonSet.
4. Decide the Kubernetes namespace for the future workload.
5. Decide the Kubernetes ServiceAccount name for the future workload.

The Pod Identity Agent is required once per cluster.

Example Terraform resource:

```hcl
resource "aws_eks_addon" "pod_identity_agent" {
  cluster_name = data.terraform_remote_state.eks.outputs.eks_cluster_name
  addon_name   = "eks-pod-identity-agent"
}
```

## 2. Terraform Resources To Provision

You need to provision these Terraform resources:

1. IAM policy with permissions for S3, SQS, Secrets Manager, and Parameter Store.
2. IAM role trusted by the EKS Pod Identity service.
3. IAM role policy attachment.
4. EKS Pod Identity Association.

## 3. IAM Policy

Create an IAM policy with only the permissions your future application needs.

Example:

```hcl
resource "aws_iam_policy" "app_aws_access" {
  name        = "${local.name}-app-aws-access"
  description = "Allows app access to S3, SQS, Secrets Manager, and SSM Parameter Store"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "S3Access"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::my-bucket",
          "arn:aws:s3:::my-bucket/*"
        ]
      },
      {
        Sid    = "SQSAccess"
        Effect = "Allow"
        Action = [
          "sqs:GetQueueUrl",
          "sqs:ReceiveMessage",
          "sqs:SendMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes"
        ]
        Resource = [
          "arn:aws:sqs:us-east-1:123456789012:my-queue"
        ]
      },
      {
        Sid    = "SecretsManagerAccess"
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = [
          "arn:aws:secretsmanager:us-east-1:123456789012:secret:my-secret-*"
        ]
      },
      {
        Sid    = "ParameterStoreAccess"
        Effect = "Allow"
        Action = [
          "ssm:GetParameter",
          "ssm:GetParameters",
          "ssm:GetParametersByPath"
        ]
        Resource = [
          "arn:aws:ssm:us-east-1:123456789012:parameter/my-app/*"
        ]
      }
    ]
  })
}
```

Replace the example ARNs with your real bucket, queue, secret, and parameter ARNs.

## 4. IAM Role For Pod Identity

Create an IAM role that can be assumed by EKS Pod Identity.

The trust principal must be `pods.eks.amazonaws.com`.

Example:

```hcl
resource "aws_iam_role" "app_pod_identity_role" {
  name = "${local.name}-app-pod-identity-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "pods.eks.amazonaws.com"
        }
        Action = [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
      }
    ]
  })
}
```

## 5. IAM Role Policy Attachment

Attach the permissions policy to the Pod Identity IAM role.

Example:

```hcl
resource "aws_iam_role_policy_attachment" "app_aws_access" {
  role       = aws_iam_role.app_pod_identity_role.name
  policy_arn = aws_iam_policy.app_aws_access.arn
}
```

## 6. EKS Pod Identity Association

Create the association between the Kubernetes ServiceAccount and the IAM role.

Example:

```hcl
resource "aws_eks_pod_identity_association" "app" {
  cluster_name    = data.terraform_remote_state.eks.outputs.eks_cluster_name
  namespace       = "my-app"
  service_account = "my-app-sa"
  role_arn        = aws_iam_role.app_pod_identity_role.arn
}
```

The `namespace` and `service_account` values must exactly match the Kubernetes manifests.

## 7. Kubernetes Manifests Needed Now

Because the Deployment will be created later, you only need these Kubernetes manifests now:

1. Namespace
2. ServiceAccount

Example namespace manifest:

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: my-app
```

Example ServiceAccount manifest:

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: my-app-sa
  namespace: my-app
```

No IAM role annotation is required for EKS Pod Identity. IAM role annotations are used by IRSA, not EKS Pod Identity.

## 8. Future Deployment Requirement

When you create the Deployment later, make sure the pod template uses the same ServiceAccount.

Example:

```yaml
spec:
  template:
    spec:
      serviceAccountName: my-app-sa
```

## 9. Recommended Setup Order

Follow this order:

1. Install or enable the EKS Pod Identity Agent add-on.
2. Decide the namespace and ServiceAccount name.
3. Create the Kubernetes namespace.
4. Create the Kubernetes ServiceAccount.
5. Create the IAM policy for S3, SQS, Secrets Manager, and Parameter Store.
6. Create the IAM role trusted by `pods.eks.amazonaws.com`.
7. Attach the IAM policy to the IAM role.
8. Create the `aws_eks_pod_identity_association`.
9. Later, create the Deployment and set `serviceAccountName` to the same ServiceAccount.

## 10. Final Checklist

| Area | What You Need | Example |
| --- | --- | --- |
| Cluster | EKS Pod Identity Agent add-on | `eks-pod-identity-agent` |
| Kubernetes | Namespace | `my-app` |
| Kubernetes | ServiceAccount | `my-app-sa` |
| IAM | Role trust principal | `pods.eks.amazonaws.com` |
| IAM | Trust actions | `sts:AssumeRole`, `sts:TagSession` |
| IAM | Permissions policy | S3, SQS, Secrets Manager, SSM |
| EKS | Pod Identity Association | Namespace + ServiceAccount + Role ARN |

## Summary

Think of this setup as an AWS permission badge system:

```text
Pod wears Kubernetes ServiceAccount badge
  -> EKS Pod Identity maps it to an AWS IAM role
  -> IAM role grants access to selected AWS services
```

The key rule is simple: the ServiceAccount name and namespace in Kubernetes must match the values used in the Terraform `aws_eks_pod_identity_association` resource.