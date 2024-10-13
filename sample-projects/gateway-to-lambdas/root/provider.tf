terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.71"
    }
  }
  required_version = ">= 1.9"
}

provider "aws" {
  region = "eu-west-2"
}
