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

data "aws_region" "current" {}

locals {
  region = data.aws_region.current.name
}
