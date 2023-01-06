terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }
  backend "s3" {
    bucket = "xyz.tochukwu-terraform-states"
    key = "isolated-envs/stage/data-store/mysql/terraform-tfstate.json"
    region = "eu-west-2"
    dynamodb_table = "terraform_states_lock"
  }
}

provider "aws" {
  region = "eu-west-2"
}

resource "aws_db_instance" "app_db" {
  engine = "mysql"
  allocated_storage = 10
  instance_class = "db.t3.micro"
  db_name = "ojlinks_db"
  username = "ojlinks_usr"
  password = var.db_password
  skip_final_snapshot = true
}