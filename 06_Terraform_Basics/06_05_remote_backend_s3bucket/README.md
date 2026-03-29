# Terraform Remote Backend Setup on AWS (S3)

This Terraform project provisions the necessary AWS infrastructure to **enable remote state management** using **Amazon S3**.

> Remote backends allow teams to securely share and lock Terraform state files, a critical requirement for collaboration and consistency in DevOps workflows.

---

## Step-01: What This Project Does
- Creates an **S3 Bucket** to store Terraform state files.
- Supports parameterization using input variables for environment-specific deployments.

---

## Step-02: File Structure

| File              | Purpose                                                                 |
|-------------------|-------------------------------------------------------------------------|
| `c1-versions.tf`   | Specifies required Terraform version and AWS provider                  |
| `c2-variables.tf`  | Declares input variables like `bucket_name`, `dynamodb_table`, etc.    |
| `c3-s3bucket.tf`   | Creates the S3 bucket for remote backend            |
| `c4-outputs.tf`    | Exposes outputs such as the bucket name and table name                 |

---

## Step-03: Example Usage

```bash
# Initialize the project
terraform init

# Preview the resources to be created
terraform plan

# Apply the configuration
terraform apply
````

---

## Implementation Steps:

To switch from loacl state to remote state, you will need to:
1. Create the S3 bucket resource and apply the configuration to provision it from local state.
2. Update your main Terraform projects to reference the new S3 backend for state management (see sample configuration below).
3. Run `terraform init` in your main projects to migrate state to the new backend.
4. Continue using Terraform as usual, with the state now stored remotely in S3.

## Sample Backend Configuration (for other Terraform projects)

Once this backend is created, use the following block in your main projects to store state remotely:

```hcl
terraform {
  backend "s3" {
    bucket         = "your-tfstate-bucket-name"
    key            = "env-name/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "your-lock-table-name"
    encrypt        = true
  }
}
```

> Replace `your-tfstate-bucket-name` and `your-lock-table-name` with actual output values from this project.

---

## Why Use Remote Backend?

* **Team Collaboration**: Prevent state conflicts when multiple people run Terraform.
* **State Locking**: Avoids race conditions using DynamoDB.
* **Durability**: S3 ensures highly available and persistent state storage.

---

## Next Step

After setting up the backend infrastructure, you can safely use it in your **main Terraform configurations** for provisioning VPCs, EKS clusters, etc.

---
