
output "cloudfront" {
  value = {
    url = "https://${var.cf_domain_name}/"
  }
}

output "lambda" {
  value = {
    url = module.lambda.url
  }
}

output "ec2" {
  value = {
    instance_id = module.alb.instance_id
  }
}
