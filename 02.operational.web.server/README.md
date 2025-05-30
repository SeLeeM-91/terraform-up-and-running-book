## Deploying One Server
In this example i created a web server on AWS  and used the user_data to start the HTTP service and to retrun a very simple html page when it is accessed also allowed the connectivity to port 8080 to access the webserver from outside 
Note: the server is created in default VPC and it is using public subnet however in real world scenario we would create this server in any  specific VPC and we would assign it ip from private subnet and create a proxy or a LB to pass trhe traffic to the server and to hide the identity of the server from outside as well ass lock the ports to allow only necessary ports needed for comunication to avoid any security risks.
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