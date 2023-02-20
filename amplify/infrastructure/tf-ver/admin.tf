resource "aws_amplify_app" "extamplifyadmin" {
    name = var.app_name_admin

    repository                      = var.repo
    # oauth_token                   = var.access_token
    # iam_service_role_arn          = aws_iam_role.amplify-access-production.arn
    iam_service_role_arn          = "arn:aws:iam::${var.aws_account}:role/AmplifyConsoleServiceRole-AmplifyRole"


    enable_auto_branch_creation   = false
    enable_basic_auth             = false
    enable_branch_auto_build      = false
    enable_branch_auto_deletion   = false

    auto_branch_creation_patterns = []
    basic_auth_credentials = false

    build_spec = <<-EOT
        version: 1
        applications:
          - backend:
              phases:
                build:
                  commands:
                    - '# Execute Amplify CLI with the helper script'
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
            appRoot: admin
            EOT

        environment_variables = {
            "AMPLIFY_AMAZON_CLIENT_ID"       = var.amplify_amazon_client_id
            "AMPLIFY_AMAZON_CLIENT_SECRET"   = var.amplify_amazon_client_secret
            "AMPLIFY_FACEBOOK_CLIENT_ID"     = var.amplify_facebook_client_id
            "AMPLIFY_FACEBOOK_CLIENT_SECRET" = var.amplify_facebook_client_secret
            "AMPLIFY_GOOGLE_CLIENT_ID"       = var.amplify_google_client_id
            "AMPLIFY_GOOGLE_CLIENT_SECRET"   = var.amplify_google_client_secret
            "AMPLIFY_DIFF_DEPLOY"            = "false"
            "AMPLIFY_IDENTITYPOOL_ID"        = var.amplify_identitypool_id
            "AMPLIFY_MONOREPO_APP_ROOT"      = "admin"
            "AMPLIFY_NATIVECLIENT_ID"        = var.amplify_nativeclient_id
            "AMPLIFY_USERPOOL_ID"            = var.amplify_userpool_id
            "AMPLIFY_WEBCLIENT_ID"           = var.amplify_webclient_id
            "_LIVE_UPDATES"                  = jsonencode(
                [
                    {
                        pkg     = "@aws-amplify/cli"
                        type    = "npm"
                        version = "9.1.0"
                    },
                    {
                        pkg     = "yarn"
                        type    = "npm"
                        version = "latest"
                    },
                    {
                        pkg     = "node"
                        type    = "nvm"
                        version = "14"
                    }
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
}

resource "aws_amplify_branch" "admin-master" {
    app_id      = aws_amplify_app.extamplifyadmin.id
    branch_name = "master"
    display_name = "master"

    # backend_environment_arn       = aws_amplify_backend_environment.master.arn

    enable_auto_build = true
    enable_pull_request_preview = false
    # pull_request_environment_name = "master"
    # stage                         = "PRODUCTION"

    environment_variables = {
              "AMPLIFY_BACKEND_APP_ID": aws_amplify_app.extamplify.id,
              "AMPLIFY_BACKEND_PULL_ONLY" = "true",
              "USER_BRANCH": "master"
            }
    ttl = 5
}

resource "aws_amplify_branch" "admin-feature-admin" {
    app_id      = aws_amplify_app.extamplifyadmin.id
    branch_name = "feature/admin"
    display_name = "feature-admin"

    # backend_environment_arn       = aws_amplify_backend_environment.master.arn

    enable_auto_build = true
    enable_pull_request_preview = false
    # pull_request_environment_name = "master"
    stage                         = "PRODUCTION"

    framework                   = "React - Amplify"

    environment_variables = {
              "AMPLIFY_BACKEND_APP_ID": aws_amplify_app.extamplify.id,
              "AMPLIFY_BACKEND_PULL_ONLY" = "true",
              "USER_BRANCH": "master"
            }
    ttl = 5
}

resource "aws_amplify_backend_environment" "admin-staging" {
    app_id           = aws_amplify_app.extamplifyadmin.id
    environment_name = "staging"
}

resource "aws_amplify_domain_association" "extamplifycomadmin" {
    app_id      = aws_amplify_app.extamplifyadmin.id
    domain_name = var.domain_name

    wait_for_verification = false
    sub_domain {
        branch_name = aws_amplify_branch.admin-master.branch_name
        prefix       = var.subdomain_name_admin
    }
}