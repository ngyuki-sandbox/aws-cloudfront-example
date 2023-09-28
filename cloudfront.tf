
resource "aws_cloudfront_distribution" "cloudfront" {
  provider = aws.cloudfront

  enabled             = true
  is_ipv6_enabled     = true
  http_version        = "http2and3"
  retain_on_delete    = false
  wait_for_deployment = false

  aliases = [var.cf_domain_name]

  origin {
    domain_name = module.alb.dns_name
    origin_id   = module.alb.dns_name

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  origin {
    domain_name              = aws_s3_bucket.private.bucket_regional_domain_name
    origin_id                = aws_s3_bucket.private.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.private.id
  }

  origin {
    domain_name = module.lambda.domain
    origin_id   = module.lambda.domain

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods         = ["GET", "HEAD"]
    viewer_protocol_policy = "https-only"
    target_origin_id       = module.alb.dns_name

    cache_policy_id          = aws_cloudfront_cache_policy.nocache.id
    origin_request_policy_id = aws_cloudfront_origin_request_policy.request.id
  }

  ordered_cache_behavior {
    path_pattern           = "/private/*"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    viewer_protocol_policy = "https-only"
    target_origin_id       = aws_s3_bucket.private.bucket_regional_domain_name

    cache_policy_id = data.aws_cloudfront_cache_policy.optimized.id
    #trusted_key_groups = [ aws_cloudfront_key_group.main.id ]
  }

  ordered_cache_behavior {
    path_pattern           = "/lambda/*"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    viewer_protocol_policy = "https-only"
    target_origin_id       = module.lambda.domain

    cache_policy_id = aws_cloudfront_cache_policy.nocache.id
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

  logging_config {
    bucket = aws_s3_bucket.log.bucket_domain_name
    prefix = "cf/"
  }

  web_acl_id = aws_wafv2_web_acl.cloudfront.arn

  depends_on = [
    aws_s3_bucket_ownership_controls.log
  ]
}

resource "aws_cloudfront_origin_access_control" "private" {
  name                              = var.name
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "tls_private_key" "main" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "aws_cloudfront_public_key" "main" {
  provider    = aws.cloudfront
  name        = var.name
  encoded_key = tls_private_key.main.public_key_pem
}

resource "aws_cloudfront_key_group" "main" {
  provider = aws.cloudfront
  name     = var.name
  items    = [aws_cloudfront_public_key.main.id]
}

data "aws_cloudfront_cache_policy" "optimized" {
  provider = aws.cloudfront
  name     = "Managed-CachingOptimized"
}

resource "aws_cloudfront_cache_policy" "nocache" {
  name    = "${var.name}-nocache"
  comment = "${var.name}-nocache"

  min_ttl     = 0
  default_ttl = 0
  max_ttl     = 0

  parameters_in_cache_key_and_forwarded_to_origin {
    cookies_config {
      cookie_behavior = "none"
    }

    headers_config {
      header_behavior = "none"
    }
    query_strings_config {
      query_string_behavior = "none"
    }
  }
}

resource "aws_cloudfront_origin_request_policy" "request" {
  name    = var.name
  comment = var.name

  cookies_config {
    cookie_behavior = "all"
  }
  headers_config {
    header_behavior = "allViewer"
  }
  query_strings_config {
    query_string_behavior = "all"
  }
}
