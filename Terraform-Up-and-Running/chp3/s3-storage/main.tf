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

# AWS recommends that you wait for 15 minutes after enabling versioning
# before issuing write operations (PUT or DELETE) on objects in the bucket.
