# ------------------------------
# Terraform configuration
# ------------------------------
terraform {
  required_version = ">=0.13"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>3.0"
    }
  }

  backend "s3" {
    encrypt = true
  }
}

# ------------------------------
# Provider
# ------------------------------
provider "aws" {
  profile = "aws-training"
  region  = var.region
}
