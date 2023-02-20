environment = "production"
key_eks              = "terraform/production/eks.tfstate"
key_certs            = "terraform/global/certs.tfstate"

###eks cluster
admin_users                              = ["admin","jenkins"]
developer_users                          = ["darek"]
asg_instance_types                       = ["r5a.large", "r5.large"]
autoscaling_minimum_size_by_az           = 1
autoscaling_maximum_size_by_az           = 1
autoscaling_average_cpu                  = 90
### cluster network
region_state_backend    = "eu-west-1"
region                  = "eu-west-1"
cluster_name            = "theapp-eks"
iac_environment_tag     = "production"
app_name                = "tehapp"


spot_termination_handler_chart_name      = "aws-node-termination-handler"
spot_termination_handler_chart_repo      = "https://aws.github.io/eks-charts"
spot_termination_handler_chart_version   = "0.18.3"
spot_termination_handler_chart_namespace = "kube-system"

# load balancer controller
lb_controller_chart_version                  = "1.4.1"

# traefik
traefik_chart_name                     = "traefik"
traefik_release_name_production        = "traefik-production"
traefik_chart_repo                     = "https://helm.traefik.io/traefik"
traefik_chart_version                  = "10.19.5"
traefik_chart_namespace                = "traefik-ingress"

dns_base_domain               = "theapp.co"
domain_cert                   = "arn:aws:acm:eu-west-1:12314124123:certificate/123123-1233-1234-1233-asdlksadk"

# k8s dashboard
kubernetes-dashboard_chart_name                     = "kubernetes-dashboard"
kubernetes-dashboard_chart_repo                     = "https://kubernetes.github.io/dashboard/"
kubernetes-dashboard_chart_version                  = "5.4.1"
kubernetes-dashboard_chart_namespace                = "default"

# datadog
datadog_chart_name                     = "datadog"
datadog_release_name                   = "datadog-agent"
datadog_chart_repo                     = "https://helm.datadoghq.com"
datadog_chart_version                  = "2.35.3"
datadog_chart_namespace                = "default"