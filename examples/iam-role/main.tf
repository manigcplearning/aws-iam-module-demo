variable "app_name" {
  description = "Application name. Maximum 7 characters."
  type        = string

  validation {
    condition     = length(var.app_name) <= 7
    error_message = "app_name must be 7 characters or fewer."
  }
}

variable "drn" {
  description = "4-digit numeric team identifier."
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
  description = "Short descriptor for the role purpose. e.g. app-role, lambda-exec."
  type        = string
}

variable "service_principal" {
  description = "AWS service principal that will assume this role. e.g. lambda.amazonaws.com, ec2.amazonaws.com."
  type        = string
}

variable "managed_policy_arns" {
  description = "List of managed policy ARNs to attach to the role."
  type        = list(string)
  default     = []
}


####################

# -------------------------------------------------------
# Local: build the name once, use it everywhere
# -------------------------------------------------------
locals {
  role_name = "${var.app_name}-${var.drn}-${var.environment}-${var.resource_key}"
}

# -------------------------------------------------------
# Trust policy — who can assume this role
# Using data source keeps the JSON clean and validated
# -------------------------------------------------------
data "aws_iam_policy_document" "trust" {
  statement {
    sid     = "AllowServiceAssume"
    effect  = "Allow"

    principals {
      type        = "Service"
      identifiers = [var.service_principal]
    }

    actions = ["sts:AssumeRole"]

    # Confused deputy protection:
    # Prevents other AWS accounts from tricking this service
    # into assuming the role on their behalf
    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }
  }
}

# -------------------------------------------------------
# Get current account ID for confused deputy condition
# -------------------------------------------------------
data "aws_caller_identity" "current" {}

# -------------------------------------------------------
# IAM Role
# -------------------------------------------------------
resource "aws_iam_role" "this" {
  name               = local.role_name
  assume_role_policy = data.aws_iam_policy_document.trust.json
  description        = "Role for ${var.app_name} — managed by Terraform"

  tags = {
    Name        = local.role_name
    AppName     = var.app_name
    DRN         = var.drn
    Environment = var.environment
  }

  lifecycle {
    prevent_destroy = true
  }
}

# -------------------------------------------------------
# Attach managed policies to the role
# for_each handles zero or many cleanly
# -------------------------------------------------------
resource "aws_iam_role_policy_attachment" "this" {
  for_each = toset(var.managed_policy_arns)

  role       = aws_iam_role.this.name
  policy_arn = each.value
}

################

output "role_name" {
  description = "Name of the IAM role."
  value       = aws_iam_role.this.name
}

output "role_arn" {
  description = "ARN of the IAM role — use this when referencing from other resources."
  value       = aws_iam_role.this.arn
}

output "role_id" {
  description = "Unique ID of the IAM role."
  value       = aws_iam_role.this.id
}
