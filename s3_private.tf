
resource "aws_s3_bucket" "private" {
  bucket_prefix = "${var.name}-private-"
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
    ]
  })

  depends_on = [aws_s3_bucket_public_access_block.private]
}

resource "aws_s3_object" "index" {
  bucket  = aws_s3_bucket.private.bucket
  key     = "private/index.html"
  content = "this is private/index.html"
}
