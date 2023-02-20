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

# get EKS authentication for being able to manage k8s objects from terraform
provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
  # load_config_file       = false
  # version                = ">= 1.9"
}

# Same parameters as kubernetes provider
provider "kubectl" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
  load_config_file       = false
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
    token                  = data.aws_eks_cluster_auth.cluster.token
    # load_config_file       = false
  }
  # version = "~> 1.2"
}

data "aws_caller_identity" "current" {} # used for accesing Account ID and ARN

