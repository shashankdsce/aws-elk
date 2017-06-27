#!/bin/bash -e
#
# Copyright © 2015 Versent Pty. Ltd.  - All Rights Reserved
# For more details please see:
# http://versent.com.au/software-licence.html
# License subject to change at Versent's discretion.
# Contact: info@versent.com.au
#


if [ -z "$AWS_DEFAULT_PROFILE" ]; then
    echo "Please set the AWS_DEFAULT_PROFILE environment variable."
    exit
fi

stack_name=$1
if [ -z "${stack_name}" ]; then
    echo "Please provide the stack name."
    exit
fi
#aws s3 sync infrastructure/ s3://build-devisland-artifact-files/api/infrastructure/ --profile devisland-lhs-build
#aws s3 sync services/ s3://build-devisland-artifact-files/api/services/ --profile devisland-lhs-build
#aws s3 sync ./infrastructure/ s3://build-devisland-artifact-files/api/ --profile $AWS_DEFAULT_PROFILE
#STACK_NUM=`date +%s`


aws cloudformation create-stack \
  --profile $AWS_DEFAULT_PROFILE \
  --region "ap-southeast-2" \
  --stack-name ${stack_name} \
  --capabilities CAPABILITY_NAMED_IAM  \
  --template-body file://master.yaml \
  --parameters \
    ParameterKey=VPCID,ParameterValue=vpc-a6e64bc3 \
    ParameterKey=SubnetPublicA,ParameterValue=subnet-17c74572 \
    ParameterKey=SubnetPublicB,ParameterValue=subnet-6578d012 \
    ParameterKey=EC2KeyName,ParameterValue=build-springdigital-provision \
    ParameterKey=HttpProxy,ParameterValue=http://proxy.apps.build.springdigital-devisland.com.au:3128 \
    ParameterKey=HttpsProxy,ParameterValue=http://proxy.apps.build.springdigital-devisland.com.au:3128 \
    ParameterKey=NoProxy,ParameterValue="169.254.169.254\,localhost\,127.0.0.1\,.apps.build.springdigital-devisland.com.au" \
    ParameterKey=GitHubUser,ParameterValue="shashankdsce" \
    ParameterKey=GitHubRepo,ParameterValue="ecs-demo-php-simple-app" \
    ParameterKey=GitHubBranch,ParameterValue="develop" \
    ParameterKey=GitHubToken,ParameterValue="b35b32f59bc10eadd2339030f619f0c82950c850" \

