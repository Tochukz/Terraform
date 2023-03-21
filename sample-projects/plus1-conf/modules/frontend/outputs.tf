output "origin_bucket_id" {
  value = aws_s3_bucket.origin_bucket.id
}
output "bucket_domain" {
  value = aws_s3_bucket.origin_bucket.bucket_domain_name 
}
output "distribution_id" {
 value = aws_cloudfront_distribution.site_dist.id
}
output "dist_domain" {
  value = aws_cloudfront_distribution.site_dist.domain_name
}