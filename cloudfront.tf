resource "aws_cloudfront_distribution" "cloudfront" {
  enabled             = true
  retain_on_delete    = false
  default_root_object = "index.html"

  origin {
    domain_name = aws_s3_bucket.public.bucket_domain_name
    origin_id   = aws_s3_bucket.public.bucket_domain_name
  }

  origin {
    domain_name = aws_s3_bucket.private.bucket_domain_name
    origin_id   = aws_s3_bucket.private.bucket_domain_name
    origin_path = "/pub"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.private.cloudfront_access_identity_path
    }
  }

  ordered_cache_behavior {
    path_pattern           = "/xxx/*"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = aws_s3_bucket.private.bucket_domain_name
    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 0
    max_ttl                = 0

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = aws_s3_bucket.public.bucket_domain_name
    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 0
    max_ttl                = 0

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

resource "aws_cloudfront_origin_access_identity" "private" {
  comment = aws_s3_bucket.private.bucket_domain_name
}
