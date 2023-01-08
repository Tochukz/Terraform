terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }
  backend "s3" {
    bucket = "xyz.tochukwu-terraform-states"
    key = "reuseable-modules/stage/services/web-cluster/terraform-tfstate.json"
    region = "eu-west-2"
    dynamodb_table = "terraform_states_lock"
  }
}

provider "aws" {
  region = "eu-west-2"
}

module "web_cluster" {
  source = "../../../modules/services/web-cluster"
  cluster_name = "staging-webcluster"
  db_state_key = "reuseable-modules/stage/data-store/mysql/terraform-tfstate.json"
  instance_type = "t2.micro"
  min_size = 2
  max_size = 2
}

resource "aws_security_group_rule" "allow_testing_on_8080" {
  type = "ingress"
  security_group_id = module.web_cluster.web_security_group_id
  from_port = 8080
  to_port = 8080
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}