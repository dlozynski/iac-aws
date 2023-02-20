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

variable "environment" {
  type        = string
  description = "AWS profile name."
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