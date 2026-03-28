terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source = "hashicorp/aws"
      # Look into the latest version of AWS provider at https://registry.terraform.io/providers/hashicorp/aws/latest
      # To lock to major versions only, use the following syntax: version = "~> 6.0" (Production BKM)
      version = ">= 6.0"
    }
  }
  # Remote Backend
  backend "s3" {
    bucket       = "tfstate-dev-us-east-1-jpjtof"
    key          = "vpc/dev/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}

provider "aws" {
  region = var.aws_region
}
