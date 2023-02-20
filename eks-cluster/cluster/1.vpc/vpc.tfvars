environment = "production"

###Cluster name and network
region                  = "eu-west-1"
cluster_name            = "theapp-eks"
cluster_version         = "1.24"
iac_environment_tag     = "production"
name_prefix              = "theapp"
main_network_block      = "10.0.0.0/16"
subnet_prefix_extension  = 4
zone_offset             = 8