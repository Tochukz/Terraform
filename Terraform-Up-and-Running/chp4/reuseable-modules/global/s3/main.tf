terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }
  backend "s3" {
    bucket = "xyz.tochukwu-terraform-states"
    key = "reuseable-modules/global/s3/terraform-tfstate.json"
    region = "eu-west-2"
    dynamodb_table = "terraform_states_lock"
  }
}

provider "aws" {
  region = "eu-west-2"
}

resource "aws_s3_bucket" "WebAppBucket" {
  bucket = "coza.tochukwu-app-bucket"
  lifecycle {
    prevent_destroy = false
  }
}

resource "aws_s3_bucket_acl" "WebAppBucketACL" {
  bucket = aws_s3_bucket.WebAppBucket.id
  acl = "private"
}

resource "aws_s3_bucket_versioning" "WebAppBucketVersioning" {
  bucket = aws_s3_bucket.WebAppBucket.id
  versioning_configuration {
    status = "Enabled"
  }
}