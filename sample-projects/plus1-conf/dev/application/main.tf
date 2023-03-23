terraform {
  backend "s3" {
    bucket = "xyz.tochukwu-terraform-states"
    key = "plus1-conf/dev/application/terraform.tfstate.json"
    region = "eu-west-2"
  }
}

module "application" {
  source = "../../modules/application"
  env_name = var.env_name
}