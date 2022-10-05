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
  }

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods         = ["GET", "HEAD"]
    viewer_protocol_policy = "https-only"
    target_origin_id       = aws_lb.main.dns_name

    cache_policy_id = aws_cloudfront_cache_policy.nocache.id
    origin_request_policy_id = aws_cloudfront_origin_request_policy.request.id
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

  logging_config {
    bucket = aws_s3_bucket.log.bucket_domain_name
    prefix = "cf/"
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

resource "aws_cloudfront_cache_policy" "nocache" {
  name    = "${var.prefix}-nocache"
  comment = "${var.prefix}-nocache"

  default_ttl = 0
  max_ttl     = 0
  min_ttl     = 0

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
  name    = var.prefix
  comment = var.prefix

  cookies_config {
    cookie_behavior = "all"
  }
  headers_config {
    header_behavior = "allViewer"
    # headers {
    #   items = ["example"]
    # }
  }
  query_strings_config {
    query_string_behavior = "all"
    # query_strings {
    #   items = ["example"]
    # }
  }
}
