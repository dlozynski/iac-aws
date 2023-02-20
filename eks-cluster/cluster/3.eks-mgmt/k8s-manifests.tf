variable "region_name" {
  type        = string
  description = "EKS cluster region name."
  default = "eu-west-1"
}


data "kubectl_path_documents" "manifests_traefik" {
    pattern = "../../manifests/traefik/ingress/*.yaml"
    vars = {
        cluster_name=var.cluster_name,
        region_name=var.region_name,
    }
}

resource "kubectl_manifest" "traefik" {
    count     = length(data.kubectl_path_documents.manifests_traefik.documents)
    yaml_body = element(data.kubectl_path_documents.manifests_traefik.documents, count.index)
}

