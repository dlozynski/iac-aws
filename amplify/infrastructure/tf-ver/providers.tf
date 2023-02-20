// Provider configuration

terraform {
    required_version = "0.12.31"

    required_providers {
        aws = "~>4.22"
    }
}

provider "aws" {
    region = "eu-west-2"
}