terraform {
  backend "s3" {
    bucket = "xyz.tochukwu-terraform-states"
    key = "chp3-standard-server/terraform-tfstate.json"
    region = "eu-west-2"
    dynamodb_table = "terraform_states_lock"
  }
}

provider "aws" {
  region = "eu-west-2"
}

resource "tls_private_key" "StandardPrivateKey" {
  algorithm = "RSA" 
  rsa_bits = 4096
}

resource "aws_key_pair" "StandardKeyPair" {
  key_name = "StandardServerKey"
  public_key = tls_private_key.StandardPrivateKey.public_key_openssh 
}

# AWS recommends that you wait for 15 minutes after enabling versioning 
# before issuing write operations (PUT or DELETE) on objects in the bucket.

# Create an S3 bucket 
# aws s3 mb s3://xyz.tochukwu-terraform-states

# Enable S3 Bucket versioning 
# aws s3api put-bucket-versioning --bucket xyz.tochukwu-terraform-states --versioning-configuration Status=Enabled

# Enable server-side encryption on the S3 bucket 
# aws s3api put-bucket-encryption --bucket xyz.tochukwu-terraform-states --server-side-encryption-configuration file://s3-encryption-config.json

# Create dynamoDB table
# aws dynamodb create-table --table-name terraform_states_lock  --attribute-definitions AttributeName=LockID,AttributeType=S  --key-schema AttributeName=LockID,KeyType=HASH  --provisioned-throughput ReadCapacityUnits=1,WriteCapacityUnits=1

# Download you remote terraform state file from S3 
# aws s3api get-object --bucket xyz.tochukwu-terraform-states --key chp3-standard-server/terraform-tfstate.json results/terraform-tfstate.json
