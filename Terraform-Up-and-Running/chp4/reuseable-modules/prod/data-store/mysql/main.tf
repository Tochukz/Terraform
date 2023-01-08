terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 4.16"
    }
  }
  backend "s3" {
    bucket = "xyz.tochukwu-terraform-states"
    key = "reuseable-modules/prod/data-store/mysql/terraform-tfstate.json"
    region = "eu-west-2"
    dynamodb_table = "terraform_states_lock"
  }
}

provider "aws" {
  region = "eu-west-2"
}

module "mysql" {
  source = "../../../modules/data-store/mysql"
  mysql_name = "prod-mysql"
  instance_class = "db.t3.micro"
  db_name = "ojlinks_prod_db"
  db_user = "ojlinksProdUsr"
  db_password = var.db_password
}