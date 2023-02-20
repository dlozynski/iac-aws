environment = "production"

###eks cluster
admin_users                              = ["admin","jenkins"]
developer_users                          = ["darek"]
asg_instance_types                       = ["r5a.large", "r5.large"]
autoscaling_minimum_size_by_az           = 1
autoscaling_maximum_size_by_az           = 1
autoscaling_average_cpu                  = 90
spot_termination_handler_chart_name      = "aws-node-termination-handler"
spot_termination_handler_chart_repo      = "https://aws.github.io/eks-charts"
spot_termination_handler_chart_version   = "0.18.3"
spot_termination_handler_chart_namespace = "kube-system"

### cluster network
region_state_backend    = "eu-west-1"
region                  = "eu-west-1"
cluster_name            = "theapp-eks"
cluster_version         = "1.24"
iac_environment_tag     = "production"
name_prefix              = "theapp"
app_name                = "theapp"

###cluster namespaces
namespaces = {
                theapp = {
                    namespace = "theapp"
                    limit    = "12288M"
                },
                traefik-ingress = {
                    namespace = "traefik-ingress"
                    limit    = "3000Mi"
                }
            }