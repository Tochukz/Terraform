# terraform {
#   backend s3 {
#     bucket = "xyz.tochukwu-terraform-states"
#     region = "eu-west-2"
#     key = "chp4/multiple-workspaces/terraform-tfstate.json"
#   }
# }

provider "aws" {
  region = "eu-west-2"
}

locals {
  key_names = {
    dev = "AmzLinuxKey2"
    staging = "UbuntuLinuxKey"
    prod = "SimpleServerKey"
  }
}

resource "aws_security_group" "security_group" {
  name = "${terraform.workspace}-web_security_group"
  ingress {
    from_port = "80"
    to_port = "80"
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTP access"
  }
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow SSH access"
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outgoing network"
  }
  tags = {
    Name = "MultipleWorkspace-${terraform.workspace}-SecurityGroup"
  }
}

resource "aws_instance" "server_instance" {
  ami = "ami-0f5470fce514b0d36"
  instance_type = terraform.workspace == "prod" ? "t2.micro" : "t2.nano"
  key_name = local.key_names[terraform.workspace]
  vpc_security_group_ids = [ aws_security_group.security_group.id ]
  user_data = file("user-data.sh")
  tags = {
    Name = "MutipleWorkspaces-${terraform.workspace}-EC2Instance"
  }
}

output "public_ip" {
  value = "${aws_instance.server_instance.public_ip}"
}