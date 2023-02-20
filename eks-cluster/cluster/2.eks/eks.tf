# create some variables
variable "admin_users" {
  type        = list(string)
  description = "List of Kubernetes admins."
}
variable "developer_users" {
  type        = list(string)
  description = "List of Kubernetes developers."
}
variable "asg_instance_types" {
  type        = list(string)
  description = "List of EC2 instance machine types to be used in EKS."
}
variable "cluster_name" {
  type        = string
  description = "EKS cluster name."
}
variable "app_name" {
  type        = string
  description = "Application name."
}
variable "cluster_version" {
  type        = string
  description = "EKS cluster name."
}
variable "iac_environment_tag" {
  type        = string
  description = "AWS tag to indicate environment name of each infrastructure object."
}
variable "name_prefix" {
  type        = string
  description = "Prefix to be used on each infrastructure object Name created in AWS."
}
variable "autoscaling_minimum_size_by_az" {
  type        = number
  description = "Minimum number of EC2 instances to autoscale our EKS cluster on each AZ."
}
variable "autoscaling_maximum_size_by_az" {
  type        = number
  description = "Maximum number of EC2 instances to autoscale our EKS cluster on each AZ."
}
variable "autoscaling_average_cpu" {
  type        = number
  description = "Average CPU threshold to autoscale EKS EC2 instances."
}
variable "spot_termination_handler_chart_name" {
  type        = string
  description = "EKS Spot termination handler Helm chart name."
}
variable "spot_termination_handler_chart_repo" {
  type        = string
  description = "EKS Spot termination handler Helm repository name."
}
variable "spot_termination_handler_chart_version" {
  type        = string
  description = "EKS Spot termination handler Helm chart version."
}
variable "spot_termination_handler_chart_namespace" {
  type        = string
  description = "Kubernetes namespace to deploy EKS Spot termination handler Helm chart."
}

# render Admin & Developer users list with the structure required by EKS module
locals {
  admin_user_map_users = [
    for admin_user in var.admin_users :
    {
      userarn  = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/${admin_user}"
      username = admin_user
      groups   = ["system:masters"]
    }
  ]
  developer_user_map_users = [
    for developer_user in var.developer_users :
    {
      userarn  = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/${developer_user}"
      username = developer_user
      groups   = ["${var.name_prefix}-developers"]
    }
  ]

  tags = {
    Name    = var.cluster_name
    App     = var.app_name
    ENV     = var.environment
    iac_environment = var.iac_environment_tag
  }
}

data "aws_vpc" "main" {
  tags = {
    Name = "${var.name_prefix}-vpc"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    iac_environment = var.iac_environment_tag
  }
}

data "aws_subnet_ids" "main" {
  vpc_id = data.aws_vpc.main.id
}

# create EKS cluster
module "eks" {
  source           = "terraform-aws-modules/eks/aws"
  version          = "18.21.0"
  cluster_name     = var.cluster_name
  cluster_version  = var.cluster_version
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true

  # cluster_addons = {
  #   coredns = {
  #     resolve_conflicts = "OVERWRITE"
  #   }
  #   kube-proxy = {}
  #   # vpc-cni = {
  #   #   resolve_conflicts        = "OVERWRITE"
  #   #   service_account_role_arn = module.vpc_cni_irsa.iam_role_arn
  #   #   addonVersion             = "v1.11.0-eksbuild.1" #does not work
  #   # }
  # }

  cluster_encryption_config = [{
    provider_key_arn = aws_kms_key.eks.arn
    resources        = ["secrets"]
  }]

  vpc_id     = data.aws_vpc.main.id
  subnet_ids = data.aws_subnet_ids.main.ids

  manage_aws_auth_configmap = true

  eks_managed_node_group_defaults = {
    ami_type = "BOTTLEROCKET_x86_64"
    platform = "bottlerocket"
    iam_role_attach_cni_policy = true
  }

  eks_managed_node_groups = {
    bottlerocket_default = {
      # By default, the module creates a launch template to ensure tags are propagated to instances, etc.,
      # so we need to disable it to use the default template provided by the AWS EKS managed node group service
      create_launch_template = false
      launch_template_name   = ""

      ami_type = "BOTTLEROCKET_x86_64"
      platform = "bottlerocket"

      disk_size = 32

      min_size     = var.autoscaling_minimum_size_by_az
      max_size     = var.autoscaling_maximum_size_by_az
      desired_size = var.autoscaling_minimum_size_by_az

      instance_types = var.asg_instance_types
      capacity_type  = "SPOT"
      force_update_version = true
      use_name_prefix = true
      ebs_optimized           = true
      disable_api_termination = false
      enable_monitoring       = true

      update_config = {
        max_unavailable_percentage = 50
      }

      labels = local.tags

      tags = local.tags
    }
  }

  # map developer & admin ARNs as kubernetes Users
  aws_auth_users = concat(local.admin_user_map_users, local.developer_user_map_users)

  #Enable logging
  cluster_enabled_log_types = []
  cloudwatch_log_group_retention_in_days = 90
}

# get EKS cluster info to configure Kubernetes and Helm providers
data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}


resource "aws_kms_key" "eks" {
  description             = "EKS Secret Encryption Key"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  tags = local.tags
}

data "aws_ami" "amazon-bottlerocket" {
  most_recent = true

  owners = ["amazon"]

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

  filter {
    name = "architecture"
    values = ["x86_64"]
    # values = ["arm64"]
  }

  filter {
    name   = "name"
    values = ["bottlerocket-aws-k8s-${var.cluster_version}-*"]
  }
}
