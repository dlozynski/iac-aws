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
variable "cluster_name" {
  type        = string
  description = "EKS cluster name."
}
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

variable "traefik_chart_name" {
  type        = string
  description = "EKS Spot termination handler Helm chart name."
}
variable "traefik_release_name_production" {
  type        = string
  description = "EKS Spot termination handler Helm chart name."
}
variable "traefik_release_name_staging" {
  type        = string
  description = "EKS Spot termination handler Helm chart name."
}
variable "traefik_chart_repo" {
  type        = string
  description = "EKS Spot termination handler Helm repository name."
}
variable "traefik_chart_version" {
  type        = string
  description = "EKS Spot termination handler Helm chart version."
}
variable "traefik_chart_namespace" {
  type        = string
  description = "Kubernetes namespace to deploy EKS Spot termination handler Helm chart."
}
# create some variables
variable "dns_base_domain" {
  type        = string
  description = "DNS Zone name to be used from EKS Ingress."
}
variable "domain_cert" {
  type        = string
  description = "Domain Certificate to be used from EKS Ingress."
}

variable "kubernetes-dashboard_chart_name" {
  type        = string
  description = "EKS Spot termination handler Helm chart name."
}
variable "kubernetes-dashboard_chart_repo" {
  type        = string
  description = "EKS Spot termination handler Helm repository name."
}
variable "kubernetes-dashboard_chart_version" {
  type        = string
  description = "EKS Spot termination handler Helm chart version."
}
variable "kubernetes-dashboard_chart_namespace" {
  type        = string
  description = "Kubernetes namespace to deploy EKS Spot termination handler Helm chart."
}
variable "key_eks" {
  type        = string
  description = "AWS EKS profile name."
}
variable "key_certs" {
  type        = string
  description = "AWS EKS profile name."
}
variable "lb_controller_chart_version" {
  type        = string
  description = "AWS Load Balancer controller Helm chart version."
}
variable "ingress_gateway_chart_name" {
  type        = string
  description = "Ingress Gateway Helm chart name."
}
variable "ingress_gateway_release_name_production" {
  type        = string
  description = "Ingress Gateway Helm chart name."
}
variable "ingress_gateway_release_name_staging" {
  type        = string
  description = "Ingress Gateway Helm chart name."
}

variable "ingress_gateway_chart_repo" {
  type        = string
  description = "Ingress Gateway Helm repository name."
}
variable "ingress_gateway_chart_version" {
  type        = string
  description = "Ingress Gateway Helm chart version."
}
variable "ingress_gateway_chart_chart_namespace_dev" {
  type        = string
  description = "Ingress Gateway Helm chart namespace."
}
variable "ingress_gateway_chart_chart_namespace_acc" {
  type        = string
  description = "Ingress Gateway Helm chart namespace."
}
variable "ingress_gateway_chart_chart_namespace_prod" {
  type        = string
  description = "Ingress Gateway Helm chart namespace."
}
variable "ingress_gateway_chart_chart_namespace" {
  type        = string
  description = "Ingress Gateway Helm chart namespace."
}
variable "ingress_gateway_annotations" {
  type        = map(string)
  description = "Ingress Gateway Annotations required for EKS."
}

variable "datadog_chart_name" {
  type        = string
  description = "EKS Spot termination handler Helm chart name."
}
variable "datadog_release_name" {
  type        = string
  description = "EKS Spot termination handler Helm chart name."
}
variable "datadog_chart_repo" {
  type        = string
  description = "EKS Spot termination handler Helm repository name."
}
variable "datadog_chart_version" {
  type        = string
  description = "EKS Spot termination handler Helm chart version."
}
variable "datadog_chart_namespace" {
  type        = string
  description = "Kubernetes namespace to deploy EKS Spot termination handler Helm chart."
}



locals {
  tags = {
    Name    = var.cluster_name
    App     = var.app_name
    ENV     = var.environment
    iac_environment = var.iac_environment_tag
  }
}

# get EKS cluster info to configure Kubernetes and Helm providers
data "aws_eks_cluster" "cluster" {
  # name = module.eks-cluster.cluster_id
  name = var.cluster_name
  tags = {
    Name = var.cluster_name
    ENV = var.iac_environment_tag
  }
}

data "aws_eks_cluster_auth" "cluster" {
  name = data.aws_eks_cluster.cluster.id
}

data "terraform_remote_state" "eks" {
  backend = "s3"
  config = {
    region = var.region_state_backend
    profile = var.profile
    bucket = var.bucket
    key    = var.key_eks
    workspace_key_prefix = var.workspace_key_prefix
    dynamodb_table =  var.dynamodb_table
    encrypt = true
  }
}

# deploy spot termination handler
resource "helm_release" "spot_termination_handler" {
  name       = var.spot_termination_handler_chart_name
  chart      = var.spot_termination_handler_chart_name
  repository = var.spot_termination_handler_chart_repo
  version    = var.spot_termination_handler_chart_version
  namespace  = var.spot_termination_handler_chart_namespace

  recreate_pods = true
  force_update  = true

  set {
    name  = "enableRebalanceMonitoring"
    value = "true"
  }
}

# load balancer controller
module "eks-lb-controller" {
  source  = "DNXLabs/eks-lb-controller/aws"
  version = "0.6.0"

  enabled = true

  cluster_identity_oidc_issuer     = data.terraform_remote_state.eks.outputs.cluster_oidc_issuer_url
  cluster_identity_oidc_issuer_arn = data.terraform_remote_state.eks.outputs.oidc_provider_arn
  cluster_name                     = data.terraform_remote_state.eks.outputs.cluster_id
  helm_chart_version               = var.lb_controller_chart_version
}

# kubernetes dashboard
resource "helm_release" "kubernetes-dashboard" {
  name       = var.kubernetes-dashboard_chart_name
  chart      = var.kubernetes-dashboard_chart_name
  repository = var.kubernetes-dashboard_chart_repo
  version    = var.kubernetes-dashboard_chart_version
  namespace  = var.kubernetes-dashboard_chart_namespace

  recreate_pods = true
  force_update  = true
  wait          = true

  values = [
    file("valueKubernetes-Dashboard.yaml")
  ]
}

# Find a certificate issued by (not imported into) ACM
data "aws_acm_certificate" "theapp_amazon_issued" {
  domain      = var.dns_base_domain
  types       = ["AMAZON_ISSUED"]
  most_recent = true
  tags = {
    App     = var.app_name
    ENV     = var.environment
    iac_environment = var.iac_environment_tag
  }
}

# deploy traefik
resource "helm_release" "traefik-prod" {
  name       = var.traefik_release_name_production
  chart      = var.traefik_chart_name
  repository = var.traefik_chart_repo
  version    = var.traefik_chart_version
  namespace  = var.traefik_chart_namespace

  recreate_pods = true
  force_update  = true
  wait          = true

  values = [
    file("valuesTraefikIngress-production.yaml")
  ]

  set {
    name  = "service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-ssl-cert"
    value = data.aws_acm_certificate.theapp_amazon_issued.arn
    type  = "string"
  }
}

# datadog monitoring helm
resource "helm_release" "datadog" {
  name       = var.datadog_release_name
  chart      = var.datadog_chart_name
  repository = var.datadog_chart_repo
  version    = var.datadog_chart_version
  namespace  = var.datadog_chart_namespace

  recreate_pods = true
  force_update  = true
  wait          = true


  values = [
    file("valuesDatadogAgent.yaml")
  ]
}