provider "aws" {
    profile = "terraform-dev"
    region = "us-east-1"
}

variable "server_port" {
    description = "this is the port for the web server"
    type = number
    default = 8080
}
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

output "web_server_public_ip" {
    value = aws_instance.webserver.public_ip
    description = "the public ip of the web server"
}

