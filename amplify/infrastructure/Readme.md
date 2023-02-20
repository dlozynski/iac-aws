# Setup Infrastructure

You will find in this location two folders - production and staging.
Production is meant for live system and staging for development.

## Preparation

Before start please install:

- Terraform 1.2.5
  - `https://learn.hashicorp.com/tutorials/terraform/install-cli`
- amplify cli - version 9.0.0
  - `npm install -g @aws-amplify/cli@9.0.0`
  - follow this guide for more setup <https://docs.amplify.aws/cli/start/install/>

## Get access token

### Create consumer on bitbucket account

Go to Bitbucket account

Click on your account profile name -> settings. Under OAuth Consumers, click add consumers.

Set callback url to http://localhost:3000 Note: this was never used, but couldnt get it to work without setting something.
Check 'This is private consumer'

Permissions:
    Repositories -> Admin
    Webhooks -> Read and Write
    Pull Requests -> Read

Once created, make a note of the key and secret, as it will be used in the next step.

### Collect access token

    curl -X POST -u "key:secret" <https://bitbucket.org/site/oauth2/access_token> -d grant_type=client_credentials

   Store it for later usage in tfvars file. It will be explained in next step.

## Create tfvars file

    create main.tfvars file in folder where main.tf is located

    edit it and add two variables
        app_name                = "[NAME of Your APP]"
        access_token            = "[TOKEN of Your User to Access Bitbucket Repository]"

## Create Main app Environment

    1. Go to [Repository Root]/infrastructure/staging directory
    2. check variable file, refresh access_token value - it is invalid after few days
    3. initiate terraform environment - `terraform init`
    4. Go to main.tf and Disable blocks of code, responsible for link to master and staging
       1. Line 96 and 119 with block backend_environment_arn
       2. All block of aws_amplify_backend_environment
          1. master - lines 133 - 140
          2. staging - lines 142 - 149
          3. stagingtwo - lines 151 - 158
    5. plan environment with plan file - `terraform plan -var-file=main.tfvars -out=main.tfplan`
    6. start terraforming - `terraform apply main.tfplan`
    7. create amplify backend
       1. Go to AWS Amplify, enter the app, and note down APP ID from App Settings/General/App Details/App ARN (last block of ARN)
       2. Execute `amplify configure --appId [Your app ID here]` and follow the instructions
       3. Extract amplify.zip in Repository Root. All files from archive should be in [Repository Root]/amplify
       4. Remove team-provider-info.json or move to folder outside
       5. Create your Facebook App, Amazon App, Google web client. You will need ID of this Apps leter. For experimental usage you can use our test apps about which it is mentioned in point 6.5.5
       6. Run command `amplify init --appId [app_id]` it will ask few questions. answers below
          1. Do you want use profile - chose default
          2. Do you want use existing environment - chose No
          3. Provide name of environment - staging for staging branch, master for master branch
          4. cli will start initialization of stack
          5. Enter Providers details, values are in file [Repository Root]/amplify/backend/awscloudformation/build/awscloudformation/build/root-cloudformation-stack.json
             1. Facebook ID and secret
             2. Google ID and secret
             3. Amazon ID and secret
       7. Run command `amplify push`, it will ask some questions. answers below
          1. Are you sure you want to continue - Y
          2. Wait few minutes to cloudformation to complete initialization
       8. At the end of initialization, you should see 'All resources are updated in the cloud' and URLs of endpoints
       9.  Test last links, it will show Login form
       10. Repeat from subpoint 1. for each backend env (master and staging)
    8. Go to main.tf and Enable blocks of code, responsible for link to master and staging
       1. Line 104 and 124
       2. Block of aws_amplify_backend_environment
          1. master - lines 136 - 139
          2. staging - lines 141 - 144
    9. Import backend resources
       1. `terraform import -var-file=main.tfvars aws_amplify_backend_environment.staging [app_id]/staging`
       2. `terraform import -var-file=main.tfvars aws_amplify_backend_environment.master [app_id]/master`
       3. In each case wait for Import sucessful
    10. run terraform
       4.  `terraform plan -var-file=main.tfvars -out=main.tfplan`
       5.  `terraform apply "main.tfplan`
    11. To install Admin application rerun steps from point 10.
    12. Admin backend
        1.  In case you install backend from scratch follow steps from point 7.
        2.  In case you have backend created follow steps from ../admin/Admin.md to add admin backend resources to master backend.
