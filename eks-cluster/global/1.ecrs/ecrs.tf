# create some variables
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

variable "ecr_name_theapp-base" {
  type        = string
  description = "Application name."
}
variable "ecr_name_theapp" {
  type        = string
  description = "Application name."
}
variable "ecr_name_traefik" {
  type        = string
  description = "Application name."
}
variable "ecr_name_theapp-frontend" {
  type        = string
  description = "Application name."
}


# ECRs

locals {
  name   = "ecr-ex-${replace(basename(path.cwd), "_", "-")}"

  tags = {
    App     = var.app_name
    ENV     = var.environment
    iac_environment = var.iac_environment_tag
    owner   = "terraform"
  }
}

################################################################################
# ECR Repository
################################################################################

module "ecr_theapp-base" {
  source = "terraform-aws-modules/ecr/aws"

  repository_name = var.ecr_name_theapp-base

  repository_image_scan_on_push = false

  repository_image_tag_mutability = "MUTABLE"

  repository_lifecycle_policy = jsonencode({
    rules = [
      {
        rulePriority = 10,
        description  = "Keep last 200 images",
        selection = {
          tagStatus     = "any",
          countType     = "imageCountMoreThan",
          countNumber   = 200
        },
        action = {
          type = "expire"
        }
      },
            {
        rulePriority = 2,
        description  = "Remove untagged",
        selection = {
          tagStatus     = "untagged",
          countType     = "imageCountMoreThan",
          countNumber   = 1
        },
        action = {
          type = "expire"
        }
      }
    ]
  })

  tags = local.tags
}


#
module "ecr_theapp" {
  source = "terraform-aws-modules/ecr/aws"

  repository_name = var.ecr_name_theapp

  repository_image_scan_on_push = false

  repository_image_tag_mutability = "MUTABLE"

  repository_lifecycle_policy = jsonencode({
    rules = [
      {
        rulePriority = 10,
        description  = "Keep last 200 images",
        selection = {
          tagStatus     = "any",
          countType     = "imageCountMoreThan",
          countNumber   = 200
        },
        action = {
          type = "expire"
        }
      },
            {
        rulePriority = 2,
        description  = "Remove untagged",
        selection = {
          tagStatus     = "untagged",
          countType     = "imageCountMoreThan",
          countNumber   = 1
        },
        action = {
          type = "expire"
        }
      }
    ]
  })

  tags = local.tags
}

#
module "ecr_traefik" {
  source = "terraform-aws-modules/ecr/aws"

  repository_name = var.ecr_name_traefik

  repository_image_scan_on_push = false

  repository_image_tag_mutability = "MUTABLE"

  repository_lifecycle_policy = jsonencode({
    rules = [
      {
        rulePriority = 10,
        description  = "Keep last 200 images",
        selection = {
          tagStatus     = "any",
          countType     = "imageCountMoreThan",
          countNumber   = 200
        },
        action = {
          type = "expire"
        }
      },
            {
        rulePriority = 2,
        description  = "Remove untagged",
        selection = {
          tagStatus     = "untagged",
          countType     = "imageCountMoreThan",
          countNumber   = 1
        },
        action = {
          type = "expire"
        }
      }
    ]
  })

  tags = local.tags
}
#
module "ecr_theapp-frontend" {
  source = "terraform-aws-modules/ecr/aws"

  repository_name = var.ecr_name_theapp-frontend

  repository_image_scan_on_push = false

  repository_image_tag_mutability = "MUTABLE"

  repository_lifecycle_policy = jsonencode({
    rules = [
      {
        rulePriority = 10,
        description  = "Keep last 200 images",
        selection = {
          tagStatus     = "any",
          countType     = "imageCountMoreThan",
          countNumber   = 200
        },
        action = {
          type = "expire"
        }
      },
            {
        rulePriority = 2,
        description  = "Remove untagged",
        selection = {
          tagStatus     = "untagged",
          countType     = "imageCountMoreThan",
          countNumber   = 1
        },
        action = {
          type = "expire"
        }
      }
    ]
  })

  tags = local.tags
}