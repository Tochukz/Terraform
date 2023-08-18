terraform {
  required_version = ">= 1.5.5"
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = ">= 5.0"      
    }
  }
}

resource "aws_instance" "ubuntu_server" {
 ami = "ami-0244a5621d426859b"
 instance_type = "t2.micro"
 tags = {
   Name = "SimpleImportedEC2"
 }
}