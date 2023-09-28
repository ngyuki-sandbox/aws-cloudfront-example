
output "cloudfront" {
  value = {
    urls = [
      "https://${var.cf_domain_name}/",
      "https://${var.cf_domain_name}/${module.s3.path}",
      "https://${var.cf_domain_name}/lambda/${module.s3.path}",
    ]
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
