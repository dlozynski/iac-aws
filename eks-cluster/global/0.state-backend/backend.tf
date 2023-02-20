variable "bucket" {
  type        = string
  description = "EKS cluster region name."
}

variable "key" {
  type        = string
  description = "AWS profile name."
}

variable "workspace_key_prefix" {
  type        = string
  description = "AWS profile name."
}

variable "dynamodb_table" {
  type        = string
  description = "EKS cluster region name."
}

terraform {
  backend "s3" {}
}

data "terraform_remote_state" "state" {
  backend = "s3"
  config = {
    region = var.region
    profile = var.profile
    bucket = var.bucket
    key    = var.key
    workspace_key_prefix = var.workspace_key_prefix
    dynamodb_table =  var.dynamodb_table
    encrypt = true
  }
}

# configure s3 bucket for tf state
resource "aws_s3_bucket" "this" {
  bucket = var.bucket

  lifecycle {
    prevent_destroy = true
  }

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  tags = {
    Environment = var.environment
    Terraform   = "true"
  }
}

# configure aws dynamodb table for state locks
resource "aws_dynamodb_table" "terraform_locks" {
  name         = var.dynamodb_table
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Environment = var.environment
    Terraform   = "true"
  }
}