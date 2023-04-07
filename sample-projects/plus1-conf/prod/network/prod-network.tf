terraform {
  backend "s3" {
    bucket = "xyz.tochukwu-terraform-states"
    key = "plus1-conf/prod/network/terraform.tfstate.json"
    region = "eu-west-2"
  }
}

provider "aws" {
  region = var.region
}

module "network" {
  source = "../../modules/network"
  env_name = var.env_name
  region = var.region
}