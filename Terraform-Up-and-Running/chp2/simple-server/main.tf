terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }
}

provider "aws" {
  region = "eu-west-2"
}

variable "server_port" {
  description = "Port for HTTP request"
  default = 80
}

variable "key_name" {
  description = "Key name of existing keypair"
  default = "AmzLinuxKey2"
}

variable "amazon_linux2_ami" {
  description = "Amazon linux2 AMI"
  default = "ami-09dca206ba8b0b1cc"
}

resource "aws_security_group" "web_security_group" {
  name = "simple_server_sg"
  ingress {
    from_port= var.server_port
    to_port = var.server_port
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 22 
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "simple_server" {
  ami = var.amazon_linux2_ami
  instance_type = "t2.micro"
  vpc_security_group_ids = ["${aws_security_group.web_security_group.id}"]
  key_name =  var.key_name
  tags = {
    Name = "ExampleAppServerInstance"
  }
  user_data = file("user-data.sh")
}

output "public_ip" {
  value = aws_instance.simple_server.public_ip
}
