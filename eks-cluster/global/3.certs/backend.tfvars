region               = "eu-west-1"
profile               = "default"
bucket               = "tf-state-iac"
dynamodb_table       = "global.tf-state-lock"
key                  = "terraform/global/certs.tfstate"
workspace_key_prefix  = "terraform/production"