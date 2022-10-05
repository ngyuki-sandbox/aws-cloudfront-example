################################################################################
# Output
################################################################################

output "urls" {
  value = [
    "https://${aws_s3_bucket.private.bucket_regional_domain_name}/index.html",

    "https://${aws_cloudfront_distribution.cloudfront.domain_name}/",
    "https://${aws_cloudfront_distribution.cloudfront.domain_name}/private/index.html",

    "https://${var.cf_domain_name}/",
  ]
}

output "log" {
  value = {
    bucket = aws_s3_bucket.log.id
  }
}
