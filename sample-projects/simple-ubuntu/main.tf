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
      ami = "ami-01dd271720c1ba44f" # Ubuntu Server 22.04 LTS (HVM) 64-bit (x86)
    }
    eu-west-2 = {
      ami = "ami-0eb260c4d5475b901" # Ubuntu Server 22.04 LTS (HVM) 64-bit (x86)
    }
    eu-west-3 = {
      ami = "ami-05b5a865c3579bbc4" # Ubuntu Server 22.04 LTS (HVM) 64-bit (x86)
    }
  }
}


resource "aws_key_pair" "keypair" {
  key_name = "SimpleEC2_KeyPair"
  public_key = file("./keys/simple-ubuntu.pub")
}

resource "aws_security_group" "web_security_group" {
  name = "SimpleUbuntuWebSG"
  description = "Allows incoming HTTP/HTTPS, SSH access and all outgoing requests"
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    # Public browser access is needed for public server
    #tfsec:ignore:aws-ec2-no-public-ingress-sgr
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all incoming HTTP requests"
  }
  ingress {
    to_port = 443
    from_port = 443
    protocol = "tcp"
    # Public browser access is needed for public server
    #tfsec:ignore:aws-ec2-no-public-ingress-sgr
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
    # Instance need internet access to install needed dependencies
    #tfsec:ignore:aws-ec2-no-public-egress-sgr
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
  security_groups = [aws_security_group.web_security_group.name]
  associate_public_ip_address = true
  user_data =file("${path.module}/user-data.sh")
  root_block_device {
    encrypted = true
  }
  metadata_options {
    http_tokens = "required"
  }
  tags = {
    Name = "SimpleEC2Ubuntu"
  }
}
