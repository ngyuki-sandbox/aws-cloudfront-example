
resource "aws_wafv2_web_acl" "cloudfront" {
  provider = aws.cloudfront

  name        = "${var.prefix}-waf"
  description = "${var.prefix}-waf"
  scope       = "CLOUDFRONT"

  default_action {
    block {}
  }

  visibility_config {
    cloudwatch_metrics_enabled = false
    metric_name                = "${var.prefix}-waf"
    sampled_requests_enabled   = false
  }

  rule {
    name     = "rule-1"
    priority = 1

    action {
      allow {}
    }

    statement {
      ip_set_reference_statement {
        arn = aws_wafv2_ip_set.cloudfront.arn
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = false
      metric_name                = "${var.prefix}-waf"
      sampled_requests_enabled   = false
    }
  }
}

resource "aws_wafv2_ip_set" "cloudfront" {
  provider = aws.cloudfront

  name               = "${var.prefix}-waf-ips"
  description        = "${var.prefix}-waf-ips"
  scope              = "CLOUDFRONT"
  ip_address_version = "IPV4"
  addresses          = var.allow_ips
}
