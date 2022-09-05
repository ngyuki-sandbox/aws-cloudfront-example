resource "aws_cloudfront_distribution" "cloudfront" {
  provider = aws.cloudfront

  enabled             = true
  is_ipv6_enabled     = true
  http_version        = "http2and3"
  retain_on_delete    = false
  wait_for_deployment = false

  aliases = [var.cf_domain_name]

  origin {
    domain_name = aws_lb.main.dns_name
    origin_id   = aws_lb.main.dns_name

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  origin {
    domain_name = aws_s3_bucket.private.bucket_regional_domain_name
    origin_id   = aws_s3_bucket.private.bucket_regional_domain_name

    origin_access_control_id = aws_cloudfront_origin_access_control.private.id
    # s3_origin_config {
    #   origin_access_identity = aws_cloudfront_origin_access_identity.private.cloudfront_access_identity_path
    # }
  }

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods         = ["GET", "HEAD"]
    viewer_protocol_policy = "https-only"
    target_origin_id       = aws_lb.main.dns_name

    min_ttl     = 0
    default_ttl = 10
    max_ttl     = 20

    forwarded_values {
      query_string = true
      headers      = ["Host", "Origin"]
      cookies {
        forward = "all"
      }
    }
  }

  ordered_cache_behavior {
    path_pattern           = "/private/*"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    viewer_protocol_policy = "https-only"
    target_origin_id       = aws_s3_bucket.private.bucket_regional_domain_name

    cache_policy_id = data.aws_cloudfront_cache_policy.optimized.id
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate.main.arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  web_acl_id = aws_wafv2_web_acl.cloudfront.arn
}

# resource "aws_cloudfront_origin_access_identity" "private" {
#   provider = aws.cloudfront
#   comment  = aws_s3_bucket.private.bucket_regional_domain_name
# }

resource "aws_cloudfront_origin_access_control" "private" {
  name                              = var.prefix
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}


data "aws_cloudfront_cache_policy" "optimized" {
  provider = aws.cloudfront
  name     = "Managed-CachingOptimized"
}
