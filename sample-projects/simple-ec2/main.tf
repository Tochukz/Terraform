terraform {
  required_version = ">= 1.5.3"
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

locals {
  regions = {
    eu-west-1 = {
      ami = "ami-08fea9e08576c443b"
    }
    eu-west-2 = {
      ami = "ami-0055e70f580e9ae80"
    }
    eu-west-3 = {
      ami = "ami-09352f5c929bf417c"
    }
  }
}


resource "aws_key_pair" "keypair" {
  key_name = "SimpleEC2_KeyPair"
  public_key = file("./keys/simple-ec2.pub")
}

resource "aws_security_group" "web_security_group" {
  vpc_id = aws_vpc.custom_vpc.id
  name = "Plus1Conf-Web-SG"
  description = "Allows incoming HTTP/HTTPS, SSH access and all outgoing requests"
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all incoming HTTP requests"
  }
  ingress {
    to_port = 443
    from_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all incoming HTTPS requests"
  }
  ingress {
    from_port = 22
    to_port = 22 
    protocol = "tcp"
    cidr_blocks = [var.ssh_cidr_block]
    description = "Allow incoming SSH requests from IPs in cidr ${var.ssh_cidr_block}"
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outgoing requests of all kinds"
  }
  tags = {
    Name = "SimpleEC2SecurityGroup"
  }
}

resource "aws_instance" "server_instance" {
  ami = local.regions[var.region].ami
  key_name = aws_key_pair.keypair.key_name
  instance_type = var.instance_type
  vpc_security_group_ids = [aws_security_group.web_security_group.web_sg_id]
  associate_public_ip_address = true
  user_data = file("user-data.sh")
  tags = {
    Name = "SimpleEC2Ubuntu"
  }
}

