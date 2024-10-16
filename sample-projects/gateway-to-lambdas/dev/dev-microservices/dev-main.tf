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

module "microservices" {
  source = "../../modules/microservices"
  artifact_bucket = "chucks-workspace-storage"
  artifact_version = "v0.0.1"
  stage_name = "development"
  env = "dev"
  layer_version = 2
}