terraform {
  backend "s3" {
    bucket = "xyz.tochukwu-terraform-states"
    key = "plus1-conf/dev/frontend/terraform.tfstate.json"
    region = "eu-west-2"
  }
}

provider "aws" {
  region = var.region
}

module "frontend" {
  source = "../../modules/frontend"
  env_name = var.env_name 
  region = var.region
  certificate_arn = "arn:aws:acm:us-east-1:966727776968:certificate/a6a0318e-0898-4e7c-ab4b-a6f0b3de4436"
  alternate_domains = ["dev.tochukwu.click", "dev-termial.tochukwu.click"]
}