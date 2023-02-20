# Cloudformation setup

## Create stack

aws cloudformation create-stack --stack-name extamplify-develop-amplifyapp --region eu-west-1 --template-body file://cf-extamplify-app.yaml --capabilities CAPABILITY_NAMED_IAM

## Update stack
aws cloudformation update-stack --stack-name extamplify-develop-amplifyapp --region eu-west-1 --template-body file://cf-extamplify-app.yaml --capabilities CAPABILITY_NAMED_IAM

## Update progess

aws cloudformation describe-stack-events --stack-name extamplify-develop-amplifyapp --region eu-west-1

aws cloudformation wait stack-update-complete --stack-name extamplify-develop-amplifyapp --region eu-west-1
## Cleanup stack

aws cloudformation delete-stack --stack-name extamplify-develop-amplifyapp --region eu-west-1

# Create Amplify backend

1. Go to AWS Amplify, enter the app, and note down APP ID from App Settings/General/App Details/App ARN (last block of ARN)
2. Execute `amplify configure --appId extamplify1234` and follow the instructions
3. Extract amplify.zip in Repository Root. All files from archive should be in [Repository Root]/amplify
4. Remove team-provider-info.json or move to folder outside
5. Create your Facebook App, Amazon App, Google web client. You will need ID of this Apps leter. For experimental usage you can use our test apps about which it is mentioned in point 6.5.5
6. Run command `amplify init --appId extamplify1234` it will ask few questions. answers below (*Note It might be that in enterprise environment you need use amplify init --permissions-boundary <IAM Policy ARN> --appId <appId>)
    1. Do you want use profile - chose default
    2. Do you want use existing environment - chose No
    3. Provide name of environment - stagingv[a] - change letter to version for staging branch, main for master branch (master env name will be not accepted)
    4. cli will start initialization of stack
    5. Enter Providers details, variables values are in file [Repository Root]/amplify/backend/awscloudformation/build/awscloudformation/build/root-cloudformation-stack.json
        1. Facebook ID and secret
        2. Google ID and secret
        3. Amazon ID and secret
        4. SES_EMAIL = extamplify.test.001@gmail.com
        5. USERPOOL = eu-west-1_xxxxxxx (it need to be change later to actual value from Cognito Service)
7. Run command `amplify push`, it will ask some questions. answers below
    1. Are you sure you want to continue - Y
    2. Do you want update graphql code - N
    3. Wait few minutes to cloudformation to complete initialization
8. At the end of initialization, you should see 'All resources are updated in the cloud' and URLs of endpoints
9. Test last links, it will show Login form
10. Repeat from subpoint 1. for each backend env (master and staging)
11. Go to Amplify console and enter your app
    1. Go to Hosting environments
    2. On each connected brach edit Continuous deploys set up
    3. Select your main amplify app in App name
    4. Select backend in Environment
    5. Deselct Enable full-stack continuous deployments
    6. Save the edit target form
