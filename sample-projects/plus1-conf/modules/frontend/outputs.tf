output "origin_bucket_name" {
  value = aws_s3_bucket.origin_bucket.bucket 
}
output "distribution_id" {
 value = aws_cloudfront_distribution.site_dist.id
}
output "dist_domain" {
  value = aws_cloudfront_distribution.site_dist.domain_name
}