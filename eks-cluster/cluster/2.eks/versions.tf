terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      # version = "~> 2.70.0"
    }
    helm = {
      source = "hashicorp/helm"
      # version = "~> 1.3.2"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
    random = {
      source = "hashicorp/random"
      # version = "~> 2.2.1"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      # version = ">= 1.7.0"
    }
  }
  #required_version = ">= 0.13"
}
