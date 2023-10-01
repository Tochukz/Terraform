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
  region = {
    eu-west-1 = {
      base = {
        ami = "ami-0855cc7dacc5f76eb"
      }
      core = {
        ami = "ami-01f162a082622f183"
      }
    }
    eu-west-2 = {
      base = {
        ami = "ami-06b0419db440a3686"
      }
      core = {
        ami = "ami-08c233720f1b3fac3"
      }
    }
  }
}


resource "aws_key_pair" "keypair" {
  key_name = "SimpleWindows_KeyPair"
  public_key = file("./keys/simple-windows.pub")
}

resource "aws_security_group" "web_security_group" {
  name = "SimpleWindowsWebSG"
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
    from_port = 3389
    to_port = 3389
    protocol = "tcp"
    cidr_blocks = [var.ssh_cidr_block]
    description = "Allow incoming RDP connection from IPs in cidr ${var.ssh_cidr_block}"
  }
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [var.ssh_cidr_block]
    description = "Allow incoming SSH connection from IPs in cidr ${var.ssh_cidr_block}"   
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
  ami = local.region[var.region][var.install_option].ami
  key_name = aws_key_pair.keypair.key_name
  instance_type = var.instance_type
  security_groups = [aws_security_group.web_security_group.name]
  associate_public_ip_address = true
  user_data =file("user-data.ps1")
  root_block_device {
    encrypted = true
  }
  metadata_options {
    http_tokens = "required"
  }
  tags = {
    Name = "SimpleEC2Windows-${var.install_option}"
  }
}

