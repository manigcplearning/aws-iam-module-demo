# versions.tf
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }

  # Terraform Cloud backend — workspace must be pre-configured in TFC UI
  cloud {
    organization = "demo-tf-org-gcp"

    workspaces {
      name = "aws-iam-module-demo"
    }
  }
}


# provider.tf — for OIDC auth TFC handles credentials automatically
provider "aws" {
  region = var.region
  # No access_key or secret_key needed when using OIDC
}

variable "aws_region" {
  description = "AWS region for the demo account deployment."
  type        = string
  default     = "ap-south-1"
}

variable "environment" {
  description = "Deployment environment. Must be prod or non-prod."
  type        = string
  default     = "non-prod"

  validation {
    condition     = contains(["prod", "non-prod"], var.environment)
    error_message = "environment must be prod or non-prod."
  }
}
