data "aws_iam_policy_document" "bucket_policy_doc" {
  statement {
    effect = "Allow"
    principals {
      type = "Service"
      identifiers = ["cloudfront.amazonaws.com"] 
    }
    actions = ["s3:GetObject"]
    resources = [ 
      "${aws_s3_bucket.origin_bucket.arn}/*",
    ]
  }
}

locals {
  s3_origin_id = "Plus1Conf${var.env_name}S3Origin"
}

resource "aws_s3_bucket" "origin_bucket" {
  bucket = "plus1-conf-${var.env_name}-assets"
  force_destroy = true
  tags = {
    Name = "Plus1Conf-${var.env_name}Bucket"
  }
}

resource "aws_s3_bucket_acl" "bucket_access_control" {
  bucket = aws_s3_bucket.origin_bucket.id
  acl    = "private"
}

resource "aws_s3_bucket_policy" "site_bucket_policy" {
  bucket = aws_s3_bucket.origin_bucket.id
  policy = data.aws_iam_policy_document.bucket_policy_doc.json
}

resource "aws_cloudfront_origin_access_control" "origin_access"{
  name = "plus1-conf-${var.env_name}-origin-access"
  description = "S3 origin access for cloudfront distribution"
  origin_access_control_origin_type = "s3"
  signing_behavior = "always"
  signing_protocol = "sigv4"
}

resource  "aws_cloudfront_distribution" "site_dist" {  
  default_root_object = "index.html"
  enabled = true
  aliases = var.alternate_domains

  origin {
    domain_name = aws_s3_bucket.origin_bucket.bucket_regional_domain_name
    origin_id = local.s3_origin_id
    origin_access_control_id = aws_cloudfront_origin_access_control.origin_access.id
  }
  custom_error_response {
    error_code = 403
    response_code = 200
    response_page_path = "/index.html"
  }
  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id 
    viewer_protocol_policy = var.env_name == "dev" ? "allow-all" : "redirect-to-https"
    cache_policy_id = "658327ea-f89d-4fab-a63d-7e88639e58f6" # CachingOptimized.
    # To learn more, go to CloudFront console > Policies > Cache
  }
  viewer_certificate {
    acm_certificate_arn = var.certificate_arn
    ssl_support_method = "sni-only"   
  }
  restrictions {
    geo_restriction {      
      restriction_type = "whitelist"
      locations = ["US", "CA", "GB", "DE", "NG", "ZA"] 
      # See https://www.nationsonline.org/oneworld/country_code_list.htm
    }
  }
  tags = {
    Name = "Plus1Conf-${var.env_name}-Distribution"
    Description = "CloudFront distribution for Plus1 ${var.env_name} site"
  }
}