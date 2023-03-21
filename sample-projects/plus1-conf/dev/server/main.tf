terraform {
  backend "s3" {
    bucket = "xyz.tochukwu-terraform-states"
    key = "plus1-conf/dev/server/terraform.tfstate.json"
    region = "eu-west-2"
  }
}

provider "aws" {
  region = var.region
}

module "server" {
  source = "../../modules/server"
  env_name = "dev"
  region = var.region
  instance_type = "t2.nano"
  allocation_id = "eipalloc-013e635330db3701c"
  network_state_key = "plus1-conf/dev/network/terraform.tfstate.json"
}