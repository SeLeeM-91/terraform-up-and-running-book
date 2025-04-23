## Deploying One Server
in this example i modified the code a little bit to more dynamic i used variables to set the server http port number in that way when we need to modify the server configuration specfically the port number we just change it in one place not in 3 places bu this way we avoid getting any manual error.
also i added output block to return the pulic ip of the server bu that we can test the server after deploy and confirm that everything went as expected

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
When the instance is created and it is in running state and optained the public ip you can test the web Server using the following command
```
 curl http://(Server_public_ip):8080
```
you will get the following output:
```
StatusCode        : 200
StatusDescription : OK
Content           : HELLO, World
```
clean up when you finish to avoid getting any fees from AWS:
```
terraform destroy
```