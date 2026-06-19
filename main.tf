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

# -------------------------------------------------------
# Local: build the name once, use it everywhere
# -------------------------------------------------------
locals {
  policy_name = "${var.app_name}-${var.drn}-${var.environment}-${var.resource_key}"
}

# -------------------------------------------------------
# IAM Managed Policy
# -------------------------------------------------------
resource "aws_iam_policy" "this" {
  name        = local.policy_name
  description = var.description
  policy      = var.policy_document

  tags = {
    Name        = local.policy_name
    AppName     = var.app_name
    DRN         = var.drn
    Environment = var.environment
  }

  lifecycle {
    prevent_destroy = true
  }
}

variable "app_name" {
  description = "Application name. Maximum 7 characters."
  type        = string

  validation {
    condition     = length(var.app_name) <= 7
    error_message = "app_name must be 7 characters or fewer."
  }
}

variable "drn" {
  description = "4-digit numeric team identifier assigned to the application team."
  type        = string

  validation {
    condition     = can(regex("^[0-9]{4}$", var.drn))
    error_message = "drn must be exactly 4 numeric digits."
  }
}

variable "environment" {
  description = "Deployment environment. Must be prod or non-prod."
  type        = string

  validation {
    condition     = contains(["prod", "non-prod"], var.environment)
    error_message = "environment must be prod or non-prod."
  }
}

variable "resource_key" {
  description = "Short descriptor for the policy purpose. e.g. s3-read, ec2-access."
  type        = string
}

variable "policy_document" {
  description = "JSON policy document string. Use data.aws_iam_policy_document to generate this."
  type        = string
}

variable "description" {
  description = "Human-readable description for the managed policy."
  type        = string
  default     = ""
}

variable "aws_region" {
  description = "AWS region for the demo account deployment."
  type        = string
  default     = "ap-south-1"
}
