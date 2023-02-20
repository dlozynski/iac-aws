# create some variables

variable "region" {
  type        = string
  description = "EKS cluster region name."
}

variable "profile" {
  type        = string
  description = "AWS profile name."
}

provider "aws" {
  region = var.region
  profile = var.profile
}

provider "random" {
}

data "aws_caller_identity" "current" {} # used for accesing Account ID and ARN

