################################################################################
# private

resource "aws_s3_bucket" "log" {
  bucket_prefix = "${var.prefix}-log-"
  force_destroy = true

  timeouts {
    create = "1m"
  }
}

resource "aws_s3_bucket_acl" "log" {
  bucket = aws_s3_bucket.log.id
  acl    = "private"
}

resource "aws_s3_bucket_public_access_block" "log" {
  bucket                  = aws_s3_bucket.log.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "log" {
  bucket = aws_s3_bucket.log.id

  rule {
    id     = "delete files"
    status = "Enabled"

    expiration {
      days = 1
    }
  }
}
