################################################################################
# Output
################################################################################

output "urls" {
  value = [
    "https://${aws_s3_bucket.public.bucket_domain_name}/index.html",
    "https://${aws_s3_bucket.public.bucket_domain_name}/limited/index.html",

    "https://${aws_s3_bucket.private.bucket_domain_name}/index.html",
    "https://${aws_s3_bucket.private.bucket_domain_name}/pub/index.html",
    "https://${aws_s3_bucket.private.bucket_domain_name}/pub/xxx/index.html",
    "https://${aws_s3_bucket.private.bucket_domain_name}/limited/index.html",

    "https://${aws_cloudfront_distribution.cloudfront.domain_name}/index.html",
    "https://${aws_cloudfront_distribution.cloudfront.domain_name}/xxx/index.html",
  ]
}
