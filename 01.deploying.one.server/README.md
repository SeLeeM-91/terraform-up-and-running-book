## Deploying One Server
This is a simple example to deploy one server in AWS using terraform

## Pre-requisities
* You must have Terraform installed
* You must have AWS account Free tier is ok

## Quick start
after you register to AWS and you create IAM user with the needed privileges to provesion the resources you will create by Terraform you need to configure the IAM user access key id and secret access key as environment variables :
```
$ export AWS_ACCESS_KEY_ID=(your access key id)
$ export AWS_SECRET_ACCESS_KEY=(your secret access key)
```
Or you can create a provile  like i did in this example :
```
$ aws configure --profile ProfileName
AWS Access Key ID [None]: (your access key id)
AWS Secret Access Key [None]: (your secret access key)
Default region name [None]: us-east-1
Default output format [None]:
```
Deploy the code
```
terraform init
terraformm apply
```
clean up when you finish to avoid getting any fees from AWS:
```
terraform destroy
```