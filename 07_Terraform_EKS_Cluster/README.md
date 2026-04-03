# AWS EKS Cluster Creation with Terraform

This project provisions a **production-ready Amazon EKS cluster** using Terraform.  
We build the cluster step by step, covering IAM roles, networking, node groups, and outputs.

---

## Kubernetes Architecture
![Kubernetes Architecture](../images/07_01_EKS_Cluster.png)


### Notes:
- **Master Node:**
  - **etcd** - The cluster Database. Used to store all cluster data, including the state of the cluster, configuration, and metadata.
  - **kube-apiserver** - The API server is the front-end for the Kubernetes control plane.
  - **kube-scheduler** - The scheduler is responsible for scheduling pods to run on worker nodes based on resource availability and other constraints.
  - **kube-controller-manager** - Responsible for running various controllers that manage the state of the cluster, such as the replication controller, which ensures that the desired number of replicas of a pod are running at all times.
  - **cloud-controller-manager** - The cloud controller manager is responsible for managing cloud-specific resources, such as load balancers and storage volumes.
    - **node lifecycle controller** - Responsible for managing the lifecycle of nodes in the cluster, including adding and removing nodes as needed.
    - **route controller** - Responsible for managing network routes in the cluster, ensuring that traffic is properly routed to the correct nodes and pods.
    - **service controller** - Responsible for managing Kubernetes services, which provide a stable IP address and DNS name for a set of pods. The service controller ensures that services are properly configured and that traffic is routed to the correct pods.
    - **volume controller** - Responsible for managing storage volumes in the cluster, ensuring that they are properly provisioned and attached to the correct nodes and pods.
- **Worker Node:**
  - **kubelet** - The kubelet is an agent that runs on each worker node and is responsible for managing the lifecycle of pods on that node. It communicates with the API server to receive instructions on which pods to run and monitors the health of those pods.
  - **kube-proxy** - The kube-proxy is responsible for managing network traffic to and from pods on the worker node. It ensures that traffic is properly routed to the correct pods and that network policies are enforced.
  - **Container Runtime** - The container runtime is responsible for running containers on the worker node.

## AWS EKS Cluster Architecture
![AWS EKS Cluster Architecture](../images/07_02_EKS_Cluster.png)

### Notes:

  - **Control Plane** - The control plane is managed by AWS and includes the Kubernetes API server, etcd, and other components. It is responsible for managing the overall state of the cluster and ensuring that the desired state is maintained.
    - **kubectl cli** - The kubectl command-line tool is used to interact with the Kubernetes API server and manage the cluster.
  - **VPC** - The EKS cluster is deployed within a VPC, which provides network isolation and security for the cluster.
  - **NAT Gateway** - The NAT gateway allows worker nodes in private subnets to access the internet for updates and other necessary communications while keeping them secure from direct internet exposure. 
  - **Subnets** - The cluster is deployed across multiple subnets for high availability:
    - **Public Subnets** - Used for load balancers and other resources that need to be accessible from the internet.
    - **Private Subnets** - Used for worker nodes and other resources that do not need to be directly accessible from the internet. 
  - **Worker Nodes** - The worker nodes are EC2 instances that run the Kubernetes workloads. Created in private subnets for better security.
---

## Terraform Remote State Datasource for VPC and EKS Cluster Terraform Projects 
- Sharing data across Terraform projects
![Terraform Remote State Datasource for VPC and EKS Cluster](../images/07_03_EKS_Cluster.png)

---

## Step-01: Project Structure

| File | Description |
|------|-------------|
| `c1_versions.tf` | Required Terraform + AWS provider versions |
| `c2_variables.tf` | Input variables (region, cluster name, etc.) |
| `c3_remote-state.tf` | Remote backend for Terraform state (S3 + DynamoDB) |
| `c4_datasources_and_locals.tf` | AWS data sources and local values |
| `c5_eks_tags.tf` | Common tags for resources |
| `c6_eks_cluster_iamrole.tf` | IAM role for EKS control plane |
| `c7_eks_cluster.tf` | EKS cluster resource definition |
| `c8_eks_nodegroup_iamrole.tf` | IAM role for EKS worker node groups |
| `c9_eks_nodegroup_private.tf` | Private node group configuration |
| `c10_eks_outputs.tf` | Useful Terraform outputs (kubeconfig, cluster details) |

---

## Step-02: Steps to Provision

```bash
# Terraform Initialize
terraform init

# Terraform Validate
terraform validate

# Terraform Plan
terraform plan

# Terraform Apply
terraform apply -auto-approve
```

---

## Step-03: Configure kubectl cli to access EKS cluster
```bash
# EKS kubeconfig
aws eks update-kubeconfig --name <cluster_name> --region <aws_region>

# List Kubernetes Nodes
kubectl get nodes

# List Kubernetes Pods 
kubectl get pods -n kube-system
```

## Step-04: Browse EKS Cluster features on AWS Console
- Go to AWS Console -> EKS
- Review Tabs
  - Overview
  - Resources
  - Compute
  - Networking
  - Add-ons
  - Access
  - Observability
  - Update history
  - Tags

---
