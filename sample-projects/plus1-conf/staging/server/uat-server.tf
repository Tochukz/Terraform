terraform {
  backend "s3" {
    bucket = "xyz.tochukwu-terraform-states"
    key = "plus1-conf/uat/server/terraform.tfstate.json"
    region = "eu-west-2"
  }
}

provider "aws" {
  region = var.region
}

module "server" {
  source = "../../modules/server"
  env_name = "uat"
  region = var.region
  instance_type = "t2.nano"
  allocation_id = "eipalloc-0d0b2b1373a7819db"
  network_state_key = "plus1-conf/uat/network/terraform.tfstate.json"
}