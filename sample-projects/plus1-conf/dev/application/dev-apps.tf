terraform {
  backend "s3" {
    bucket = "xyz.tochukwu-terraform-states"
    key = "plus1-conf/dev/application/terraform.tfstate.json"
    region = "eu-west-2"
  }
}

module "application" {
  source = "../../modules/application"
  region = var.region
  env_name = var.env_name
  subscribe_email = "t.nwachukwu@outlook.com"
  subscribe_endpoint = "https://api-dev.plus1.click/deployment/subscribe"
}