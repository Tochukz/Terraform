terraform {
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "~> 4.16"
    }
  }
}

provider "aws" {
  region = "eu-west-2"
}

resource "aws_instance" "simple_server" {
  ami = "ami-04706e771f950937f"
  instance_type = "t2.micro"
  tags = {
    Name = "ExampleAppServerInstance"
  }
}