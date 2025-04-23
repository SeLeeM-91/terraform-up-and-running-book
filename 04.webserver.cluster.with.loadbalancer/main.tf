provider "aws" {
    profile = "terraform-dev"
    region = "us-east-1"
}

variable "server_port" {
    description = "this is the port for the web server"
    type = number
    default = 8080
}

data "aws_vpc" "default" {
    default = true
}

data "aws_subnets" "default" {
   filter{
    name = "vpc-id"
    values = [data.aws_vpc.default.id]
   }  
}

data "template_file" "user_data" {
    template = <<-EOF
                #!/bin/bash
                echo "HELLO, World" > index.html
                nohup busybox httpd -f -p ${var.server_port} &
                EOF
}

resource "aws_launch_template" "server_specs" {
    name_prefix = "server_specs"
    image_id = "ami-0f9de6e2d2f067fca"
    instance_type = "t2.micro"
    vpc_security_group_ids = [ aws_security_group.allow-http.id ]

    
    user_data = "${base64encode(data.template_file.user_data.rendered)}"
}
resource "aws_autoscaling_group" "ASG_web_server" {
  launch_template {
    id = aws_launch_template.server_specs.id
    version = "$Latest"
  }

  vpc_zone_identifier = data.aws_subnets.default.ids
  target_group_arns = [ aws_lb_target_group.asg.arn ]
  health_check_type = "ELB"

  min_size = 2
  max_size = 10

  tag {
    key = "Name"
    value = "ASG_web_server"
    propagate_at_launch = true
  }
}

resource "aws_security_group" "allow-http" {
    name = "terraform-allow-http"
    description = "Allow web traffics"

    ingress  {
        from_port = var.server_port
        to_port = var.server_port
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
  
}

resource "aws_lb" "web-server-lb" {
    name = "web-server-lb"
    load_balancer_type = "application"
    subnets = data.aws_subnets.default.ids
    security_groups = [ aws_security_group.alb.id ]
}
resource "aws_lb_listener" "http" {
    load_balancer_arn = aws_lb.web-server-lb.arn
    port = 80
    protocol = "HTTP"
    default_action {
      type = "fixed-response"

      fixed_response {
        content_type = "text/plain"
        message_body = "404: Page not found"
        status_code = 404
      }
    } 
}

resource "aws_lb_target_group" "asg" {
    name = "asg-target-group"
    port = var.server_port
    protocol = "HTTP"
    vpc_id = data.aws_vpc.default.id

    health_check {
      path = "/"
      protocol = "HTTP"
      matcher = "200"
      interval = 15
      timeout = 3
      healthy_threshold = 2
      unhealthy_threshold = 2
    }
}

resource "aws_lb_listener_rule" "asg" {
    listener_arn = aws_lb_listener.http.arn
    priority = 100

    condition {
      path_pattern {
        values = ["*"]
      }
    }

    action {
        type = "forward"
        target_group_arn = aws_lb_target_group.asg.arn
    }
}

resource "aws_security_group" "alb" {
    name = "alb-security-group"

    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = [ "0.0.0.0/0" ]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = [ "0.0.0.0/0" ]
    }
}

output "alb-dns-name" {
    value = aws_lb.web-server-lb.dns_name
    description = "the domain name of teh load balancer"
}


/* 
Issues i faced 
1- we could use aws_launch_configuration insted of aws_lunch_template but it was not avilable to be used  on my account and i got the following error
the error i got was :
Error: creating Auto Scaling Launch Configuration (terraform-####################): operation error Auto Scaling: CreateLaunchConfiguration, 
https response error StatusCode: 400, RequestID: ####-####-####-####-##############, api error UnsupportedOperation: The Launch Configuration 
creation operation is not available in your account. Use launch templates to create configuration templates for your Auto Scaling groups.

the config will be as the following just for referance:
resource "aws_launch_configuration" "server_specs" {
    image_id = "ami-0f9de6e2d2f067fca"
    instance_type = "t2.micro"
    security_groups = [ aws_security_group.allow-http.id ]

    user_data = <<-EOF
                #!/bin/bash
                echo "HELLO, World" > index.html
                nohup busybox httpd -f -p ${var.server_port} &
                EOF
    lifecycle {
        create_before_destroy = true
    }
} 

2- in AWS_launch_template i had to add filebase64 before the user data to avoid the following error which is abit silly as it is already mentioned at terraform documentations
    operation error EC2: CreateLaunchTemplate, https response error 
    StatusCode: 400, RequestID: 979687d5-9ad5-4fa6-8825-cd4e1ff36756, api error InvalidUserData.Malformed: Invalid BASE64 encoding of user data.

3- in aws_launch_template i was using security_group_names = [ "${aws_security_group.allow-http.name}" ] and i got error
The parameter groupName cannot be used with the parameter subnet
i had to replace with
vpc_security_group_ids = [ aws_security_group.allow-http.id ]
NOte When you specify a security group for a nondefault VPC to the CLI or the API actions, you must use the security group ID and not the security group name to identify the security group.
https://stackoverflow.com/questions/31569910/terraform-throws-groupname-cannot-be-used-with-the-parameter-subnet-or-vpc-se

*/



/* 
resource "aws_instance" "webserver" {
    ami = "ami-0f9de6e2d2f067fca"
    instance_type = "t2.micro"
    vpc_security_group_ids = [aws_security_group.allow-http.id]

    user_data = <<-EOF
                #!/bin/bash
                echo "HELLO, World" > index.html
                nohup busybox httpd -f -p ${var.server_port} &
                EOF
    user_data_replace_on_change = true

    tags = {
      Name = "Web Server"
    }
}
 and ofcource you will call it on  ASG using teh following command
 launch_configuration = aws_launch_configuration.server_specs.name


 */