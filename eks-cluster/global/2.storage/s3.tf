# variables
variable "app_name" {
  type        = string
  description = "Application name."
}
variable "region_state_backend" {
  type        = string
  description = "EKS cluster name."
}
variable "iac_environment_tag" {
  type        = string
  description = "AWS tag to indicate environment name of each infrastructure object."
}

# configure s3 bucket for logs
resource "aws_s3_bucket" "lb-logs" {
  bucket = "nlb-logs"
  policy = file("s3-bucket-nlb-policy.json")

  lifecycle {
    prevent_destroy = true
  }

  versioning {
    enabled = false
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