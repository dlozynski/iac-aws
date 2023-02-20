# create some variables
variable "namespaces" {
  type = map(object({
    namespace = string
    limit    = string
  }))
  description = "List of namespaces and limits to be created in our EKS Cluster."
}

# create all Namespaces into EKS
resource "kubernetes_namespace" "eks_namespaces" {
  for_each = var.namespaces

  metadata {
    annotations = {
      name = each.key
    }
    name = each.key
  }
}

resource "kubernetes_limit_range" "eks_ns_limits" {
  for_each = var.namespaces

  metadata {
    name = "mem-limit-range"
    namespace = each.key
  }

  spec {
    limit {
      type = "Container"
      default = {
        memory =  each.value.limit
      }
      default_request = {
        memory = "128M"
      }
    }
  }
}