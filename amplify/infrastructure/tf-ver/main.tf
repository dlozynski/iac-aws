resource "aws_amplify_app" "extamplify" {
    name = var.app_name_main

    repository                    = var.repo
    oauth_token                   = var.access_token
    iam_service_role_arn          = aws_iam_role.amplify-access-production.arn

    enable_auto_branch_creation   = false
    enable_basic_auth             = false
    enable_branch_auto_build      = false
    enable_branch_auto_deletion   = true

    auto_branch_creation_patterns = []
    basic_auth_credentials = false

    build_spec = <<-EOT
                version: 1
                backend:
                  phases:
                    build:
                      commands:
                        - amplifyPush --simple
                frontend:
                  phases:
                    preBuild:
                      commands:
                        - npm ci
                    build:
                      commands:
                        - npm run build
                  artifacts:
                    baseDirectory: build
                    files:
                      - '**/*'
                  cache:
                    paths:
                      - node_modules/**/*
            EOT

        environment_variables = {
            "AMPLIFY_AMAZON_CLIENT_ID"       = var.amplify_amazon_client_id
            "AMPLIFY_AMAZON_CLIENT_SECRET"   = var.amplify_amazon_client_secret
            "AMPLIFY_FACEBOOK_CLIENT_ID"     = var.amplify_facebook_client_id
            "AMPLIFY_FACEBOOK_CLIENT_SECRET" = var.amplify_facebook_client_secret
            "AMPLIFY_GOOGLE_CLIENT_ID"       = var.amplify_google_client_id
            "AMPLIFY_GOOGLE_CLIENT_SECRET"   = var.amplify_google_client_secret
            "SES_EMAIL"                      = var.email
            "_LIVE_UPDATES"                  = jsonencode(
                [
                    {
                        pkg     = "@aws-amplify/cli"
                        type    = "npm"
                        version = "9.0.0"
                    },
                    {
                        pkg     = "node"
                        type    = "nvm"
                        version = "16"
                    },
                    {
                        pkg     = "yarn"
                        type    = "npm"
                        version = "latest"
                    },
                ]
            )
        }

        # Redirects for Single Page Web Apps (SPA)
        # https://docs.aws.amazon.com/amplify/latest/userguide/redirects.html#redirects-for-single-page-web-apps-spa
        custom_rule {
            source = "</^[^.]+$|\\.(?!(css|gif|ico|jpg|js|png|txt|svg|woff|woff2|ttf|map|json|webp)$)([^.]+$)/>"
            status = "200"
            target = "/index.html"
        }

        ## This looks like is crearted automaicly by backends
        custom_rule {
            source = "/amplify/master"
            status = "301"
            target = "https://eu-west-2.admin.amplifyapp.com/admin/d2outn85x2vmaj/master/home"
        }

        custom_rule {
            source = "/amplify/staging"
            status = "301"
            target = "https://eu-west-2.admin.amplifyapp.com/admin/d2outn85x2vmaj/staging/home"
        }
}

resource "aws_amplify_branch" "master" {
    app_id      = aws_amplify_app.extamplify.id
    branch_name = "master"
    display_name = "master"

    backend_environment_arn       = aws_amplify_backend_environment.master.arn

    enable_auto_build = true
    enable_pull_request_preview = true
    pull_request_environment_name = "pullreq"
    stage                         = "PRODUCTION"

    environment_variables = {
              "AMPLIFY_BACKEND_APP_ID": aws_amplify_app.extamplify.id,
              "AMPLIFY_BACKEND_PULL_ONLY" = "true",
              "USER_BRANCH": "master"
            }
    ttl = 5
}

resource "aws_amplify_branch" "staging" {
    app_id      = aws_amplify_app.extamplify.id
    branch_name = "staging"

    display_name = "staging"

    # backend_environment_arn       = aws_amplify_backend_environment.staging.arn

    enable_auto_build = true
    enable_pull_request_preview = false

    environment_variables = {
      "AMPLIFY_BACKEND_APP_ID": aws_amplify_app.extamplify.id,
      "AMPLIFY_BACKEND_PULL_ONLY" = "true",
      "USER_BRANCH": "stagingtwo"
    }
    ttl = 5
}

# resource "aws_amplify_backend_environment" "master" {
#     app_id           = aws_amplify_app.extamplify.id
#     environment_name = "master"

#     # deployment_artifacts = "amplify-extamplify-master-145136-deployment"

#     # stack_name = "amplify-extamplify-master-145136"
# }

# resource "aws_amplify_backend_environment" "staging" {
#     app_id           = aws_amplify_app.extamplify.id
#     environment_name = "staging"

#     # deployment_artifacts = "amplify-amplifyae1d9ce4790b4-staging-115516-deployment"

#     # stack_name = "amplify-amplifyae1d9ce4790b4-staging-115516"
# }


#Policy document specifying what service can assume the role
data "aws_iam_policy_document" "assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["amplify.amazonaws.com"]
    }
  }
}
#IAM role providing amplify admin and read-only access to CodeCommit
resource "aws_iam_role" "amplify-access-production" {
  name                = "AmplifyAccessProduction"
  assume_role_policy  = join("", data.aws_iam_policy_document.assume_role.*.json)
  managed_policy_arns = ["arn:aws:iam::aws:policy/AWSCodeCommitReadOnly",
                         "arn:aws:iam::aws:policy/AdministratorAccess-Amplify"]
}

resource "aws_amplify_domain_association" "extamplifycom" {
    app_id      = aws_amplify_app.extamplify.id
    domain_name = var.domain_name

    wait_for_verification = false
    sub_domain {
        branch_name = aws_amplify_branch.master.branch_name
        prefix       = var.subdomain_name_main
    }
}