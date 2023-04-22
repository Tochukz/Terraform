terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }
  backend "s3" {
    bucket = "xyz.tochukwu-terraform-states"
    key    = "lambda-conf/nestjs-app/terraform.tfstate.json"
    region = "eu-west-2"
  }
}

provider "aws" {
  region = "eu-west-2"
}

module "lambda_module" {
  source      = "../lambda-module"
  app_name    = "NestJS"
  app_version = var.app_version
  build_name  = "dist"
  handler     = "dist/lambda.handler"
}
