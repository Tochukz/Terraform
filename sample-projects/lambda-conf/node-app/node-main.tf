terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }
  backend "s3" {
    bucket = "xyz.tochukwu-terraform-states"
    key    = "lambda-conf/terraform.tfstate.json"
    region = "eu-west-2"
  }
}

provider "aws" {
  region = "eu-west-2"
}

module "lambda_module" {
  source      = "../lambda-module"
  app_name    = "NativeNode"
  app_version = var.app_version
  build_name  = var.build_name
  handler     = var.handler
}
