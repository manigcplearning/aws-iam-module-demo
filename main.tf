# versions.tf
terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

# provider.tf — for OIDC auth TFC handles credentials automatically
provider "aws" {
  region = var.region
  # No access_key or secret_key needed when using OIDC
}
