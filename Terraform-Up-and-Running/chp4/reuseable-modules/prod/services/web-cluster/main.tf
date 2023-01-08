terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }
  backend "s3" {
    bucket = "xyz.tochukwu-terraform-states"
    key = "reuseable-modules/prod/services/web-cluster/terraform-tfstate.json"
    region = "eu-west-2"
    dynamodb_table = "terraform_states_lock"
  }
}

provider "aws" {
  region = "eu-west-2"
}

module "web_cluster" {
  source = "../../../modules/services/web-cluster"
  cluster_name = "prod-webcluster"
  db_state_key = "reuseable-modules/prod/data-store/mysql/terraform-tfstate.json"
  instance_type = "t2.micro"
  min_size = 2
  max_size = 10
}

resource "aws_autoscaling_schedule" "scale_out_at_business_hour" {
   scheduled_action_name = "scale-out-during-business-hour"
   min_size = 2
   max_size = 10
   desired_capacity = 10
   recurrence = "0 9 * * *"
   autoscaling_group_name = module.web_cluster.autoscaling_group_name
}

resource "aws_autoscaling_schedule" "scale_in_at_might" {
  scheduled_action_name = "scale-in-at-night"
  min_size = 2
  max_size = 10
  desired_capacity = 2
  recurrence = "0 17 * * *" 
  autoscaling_group_name = module.web_cluster.autoscaling_group_name
}

# cron syntax
# (0 9 * * *)  => 9am every day
# (0 17 * * *) => 5pm every day