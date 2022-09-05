################################################################################
# private

resource "aws_s3_bucket" "private" {
  bucket_prefix = "${var.prefix}-private"
  force_destroy = true

  timeouts {
    create = "1m"
  }
}

resource "aws_s3_bucket_ownership_controls" "private" {
  bucket = aws_s3_bucket.private.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "private" {
  bucket                  = aws_s3_bucket.private.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "private" {
  bucket = aws_s3_bucket.private.id
  policy = jsonencode({
    Version : "2008-10-17",
    Statement : [
      # {
      #   Action : "s3:GetObject",
      #   Effect : "Allow",
      #   Resource : "${aws_s3_bucket.private.arn}/*",
      #   Principal : {
      #     AWS : aws_cloudfront_origin_access_identity.private.iam_arn,
      #   },
      # },
      {
        Action : "s3:GetObject",
        Effect : "Allow",
        Resource : "${aws_s3_bucket.private.arn}/*",
        Principal : {
          Service : "cloudfront.amazonaws.com",
        },
        Condition : {
          StringEquals : {
            "aws:SourceArn" : aws_cloudfront_distribution.cloudfront.arn,
          },
        },
      },
      {
        Action : "s3:GetObject",
        Effect : "Allow",
        Resource : "${aws_s3_bucket.private.arn}/*",
        Principal : "*",
        Condition : {
          IpAddress : {
            "aws:SourceIp" : var.allow_s3_ips,
          },
        },
      },
    ]
  })
}


resource "aws_s3_bucket_lifecycle_configuration" "private" {
  bucket = aws_s3_bucket.private.id

  rule {
    id     = "delete tmp files"
    status = "Enabled"

    filter {
      prefix = "tmp/"
    }

    expiration {
      days = 7
    }

    noncurrent_version_expiration {
      noncurrent_days = 1
    }

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }

  rule {
    id     = "expire old version"
    status = "Enabled"

    expiration {
      expired_object_delete_marker = true
    }

    noncurrent_version_expiration {
      noncurrent_days = 7
    }
  }
}

################################################################################
# object

resource "aws_s3_object" "private" {
  bucket  = aws_s3_bucket.private.bucket
  key     = "index.html"
  content = "this is private index.html"
}

resource "aws_s3_object" "private2" {
  bucket  = aws_s3_bucket.private.bucket
  key     = "private/index.html"
  content = "this is private private/index.html"
}
