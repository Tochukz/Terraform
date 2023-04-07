terraform {
  backend "s3" {
    bucket = "xyz.tochukwu-terraform-states"
    key = "plus1-conf/dev/database/terraform.tfstate.json"
    region = "eu-west-2"
  }
}

provider "aws" {
  region = var.region
}

module "database" {
  source = "../../modules/database"
  env_name = var.env_name 
  region = var.region
  dbname = "plus1_dev_db"
  username = "plus1_dev_user"
  password = var.password
  network_state_key = "plus1-conf/dev/network/terraform.tfstate.json"
}