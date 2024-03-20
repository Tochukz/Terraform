terraform {
  required_version = ">= 1.7"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.27"
    }
  }
}

provider "aws" {
  region = "eu-west-2"
}

resource "aws_ecr_repository" "simple_repo" {
  name = "simple-express"
}
