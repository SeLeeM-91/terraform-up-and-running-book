provider "aws" {
    profile = "terraform-dev"
    region = "us-east-1"
}

resource "aws_instance" "webserver" {
    ami = "ami-0f9de6e2d2f067fca"
    instance_type = "t2.micro"
    vpc_security_group_ids = [aws_security_group.allow-http.id]

    user_data = <<-EOF
                #!/bin/bash
                echo "HELLO, World" > index.html
                nohup busybox httpd -f -p 8080 &
                EOF
    user_data_replace_on_change = true

    tags = {
      Name = "Web Server"
    }
}

resource "aws_security_group" "allow-http" {
    name = "terraform-allow-http"
    description = "Allow web traffics"

    ingress  {
        from_port = 8080
        to_port = 8080
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
  
}

