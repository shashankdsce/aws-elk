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



#aws s3 sync infrastructure/ s3://build-devisland-artifact-files/api/infrastructure/ --profile devisland-lhs-build
#aws s3 sync services/ s3://build-devisland-artifact-files/api/services/ --profile devisland-lhs-build
#aws s3 sync ./infrastructure/ s3://build-devisland-artifact-files/api/ --profile $AWS_DEFAULT_PROFILE
#STACK_NUM=`date +%s`
#elk-1

Organisation="optus"
Account="devisland"
region="ap-southeast-2"
bucket_name="$Organisation-$Account-aem"
echo "Bucket name is ${bucket_name}"
aws s3api head-bucket --bucket "$bucket_name" --region "$region" --profile $AWS_DEFAULT_PROFILE ||
    aws s3 mb "s3://$bucket_name" --region "$region"  --profile $AWS_DEFAULT_PROFILE


aws s3 cp ./master.yaml "s3://$bucket_name/elk/" --region "$region"  --profile $AWS_DEFAULT_PROFILE

aws s3 sync cloudformation/ "s3://$bucket_name/elk/cfn/" --region "$region"  --profile $AWS_DEFAULT_PROFILE

aws s3 sync config/ "s3://$bucket_name/elk/config/" --region "$region" --profile $AWS_DEFAULT_PROFILE

aws s3api put-bucket-policy --bucket "${bucket_name}"  --policy "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Effect\":\"Allow\",\"Principal\":\"*\",\"Action\":[\"s3:GetObject\",\"s3:GetObjectVersion\"],\"Resource\":\"arn:aws:s3:::$bucket_name/*\"},{\"Effect\":\"Allow\",\"Principal\":\"*\",\"Action\":[\"s3:ListBucket\",\"s3:GetBucketVersioning\"],\"Resource\":\"arn:aws:s3:::$bucket_name\"}]}" --region "$region"

aws cloudformation create-stack \
  --profile $AWS_DEFAULT_PROFILE \
  --region "ap-southeast-2" \
  --stack-name "elk-2" \
  --capabilities CAPABILITY_NAMED_IAM  \
  --template-body file://master.yaml \
  --disable-rollback  \
  --parameters \
    ParameterKey=AllowedHttpCidr,ParameterValue="0.0.0.0/0" \
    ParameterKey=AllowedSshCidr,ParameterValue="0.0.0.0/0" \
    ParameterKey=EBSVolumeSize,ParameterValue=0 \
    ParameterKey=KibanaEBSVolumeSize,ParameterValue=0 \
    ParameterKey=LogstashEBSVolumeSize,ParameterValue=0 \
    ParameterKey=Account,ParameterValue=${Account} \
    ParameterKey=Organisation,ParameterValue=${Organisation} \
    ParameterKey=ElkCapacity,ParameterValue=1 \
    ParameterKey=LogstashCapacity,ParameterValue=1 \
    ParameterKey=KibanaCapacity,ParameterValue=1 \
    ParameterKey=LogstashCapacity,ParameterValue=1 \
    ParameterKey=IndexKeepDays,ParameterValue=8 \
    ParameterKey=InstanceType,ParameterValue="t2.medium" \
    ParameterKey=LogstashInstanceType,ParameterValue="t2.medium" \
    ParameterKey=KibanaInstanceType,ParameterValue="t2.small" \
    ParameterKey=KeyName,ParameterValue=amdocs-springdigital-versent-dev \
    ParameterKey=ProxyExcludeList,ParameterValue="169.254.169.254\,localhost\,127.0.0.1\,.apps.springdigital-devisland.com.au" \
    ParameterKey=ProxyPort,ParameterValue="3128" \
    ParameterKey=ProxyServerEndpoint,ParameterValue="proxy.apps.springdigital-devisland.com.au" \
    ParameterKey=PublicVpcSubnets,ParameterValue="subnet-02cc4967\,subnet-8471d2f3" \
    ParameterKey=PrivateVpcSubnets,ParameterValue="subnet-0dcc4968\,subnet-8571d2f2" \
    ParameterKey=SnapshotRepository,ParameterValue="devisland-elk-backup" \
    ParameterKey=Stack,ParameterValue="elasticsearch" \
    ParameterKey=Stage,ParameterValue="CODE" \
    ParameterKey=VpcId,ParameterValue=vpc-ceaf08ab \
    ParameterKey=VpcIpRangeCidr,ParameterValue=0.0.0.0/0 \
    ParameterKey=HostedZoneName,ParameterValue='' \
    ParameterKey=NginxUsername,ParameterValue='admin' \
    ParameterKey=NginxPassword,ParameterValue='admin' \
    ParameterKey=MonitorStack,ParameterValue=true

