## Deploying a Cluster of web servers
in this example i modified the code even more as you can see we had only one server which represent a single point of faliuer so here i created a cluster of web servers, using AUto Scaling Group from AWS with min size of 2 servers and max size is 10, and the servers specification is inherted from aws_launch_template, this servers will run with HTTP server running, The ASG is attached to LB with type application the ALB [Application Load Balancer] will get requests from end user on port 80 HTTP (ELB [AWS Elastic Load Balancer] listener) and will comunicate with ASG (ELB Target group) using port 8080 to get the HTTP content back to the user this will hide the identity of the server from attackers, there will be health check done by ALB by periodically check the server and see i case it is not reachable or it is not retruning 200 response to HTTP traffic it will trigger auto healing and fire new server  instead of the down one so at any time you will have at least 2 server up and runing  and in case the load to this 2 server become more than they can handel another server will be deployed  till max of 10 servers

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
When the load balancer and servers are created and it is in running state the output block will retrun the DNS name to the Load Balancer you can http this DNS name you will get the http content back from server.
To make sure the Load balancer is working as expected and is dowing health check to the servers  shutdown one of the servers after the threshold another server will be created automatically

clean up when you finish to avoid getting any fees from AWS:
```
terraform destroy
```