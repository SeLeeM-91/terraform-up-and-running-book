provider "aws" {
    profile = "terraform-dev"
    region = "us-east-1"
}

resource "aws_instance" "webserver" {
    ami = "ami-0f9de6e2d2f067fca"
    instance_type = "t2.micro"

    tags = {
      Name = "Web Server"
    }
}

