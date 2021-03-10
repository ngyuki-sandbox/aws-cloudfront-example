################################################################################
# S3
################################################################################

resource "aws_s3_bucket" "public" {
  bucket = "${var.prefix}-public"
  #acl           = "public-read"
  acl           = "private"
  force_destroy = false
}

resource "aws_s3_bucket_policy" "public" {
  bucket = aws_s3_bucket.public.id
  policy = jsonencode({
    Version : "2008-10-17",
    Statement : [
      {
        Action : "s3:GetObject",
        Effect : "Allow",
        Resource : "${aws_s3_bucket.public.arn}/*",
        Principal : "*",
      },
      {
        Action : "s3:GetObject",
        Effect : "Deny",
        Resource : "${aws_s3_bucket.public.arn}/limited/*",
        "Condition" : {
          "NotIpAddress" : {
            "aws:SourceIp" : var.my_ips,
          },
        },
        "Principal" : "*",
      },
    ]
  })
}

resource "aws_s3_bucket" "private" {
  bucket        = "${var.prefix}-private"
  acl           = "private"
  force_destroy = false
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
        Resource : "${aws_s3_bucket.private.arn}/pub/*",
        Principal : {
          AWS : aws_cloudfront_origin_access_identity.private.iam_arn,
        },
      },
      {
        Action : "s3:GetObject",
        Effect : "Allow",
        Resource : "${aws_s3_bucket.private.arn}/limited/*",
        "Condition" : {
          "IpAddress" : {
            "aws:SourceIp" : var.my_ips,
          },
        },
        "Principal" : "*",
      },
    ]
  })
}

resource "aws_s3_bucket_object" "public" {
  bucket  = aws_s3_bucket.public.bucket
  key     = "index.html"
  content = "this is public index.html"
}

resource "aws_s3_bucket_object" "public_limited" {
  bucket  = aws_s3_bucket.public.bucket
  key     = "limited/index.html"
  content = "this is public limited/index.html"
}

resource "aws_s3_bucket_object" "private" {
  bucket  = aws_s3_bucket.private.bucket
  key     = "index.html"
  content = "this is private index.html"
}

resource "aws_s3_bucket_object" "private_pub" {
  bucket  = aws_s3_bucket.private.bucket
  key     = "pub/index.html"
  content = "this is private pub/index.html"
}

resource "aws_s3_bucket_object" "private_pub_xxx" {
  bucket  = aws_s3_bucket.private.bucket
  key     = "pub/xxx/index.html"
  content = "this is private pub/xxx/index.html"
}

resource "aws_s3_bucket_object" "private_limited" {
  bucket  = aws_s3_bucket.private.bucket
  key     = "limited/index.html"
  content = "this is private limited/index.html"
}
