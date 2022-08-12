
provider "aws" {
  region = var.region
}

provider "aws" {
  alias  = "cloudfront"
  region = "us-east-1"
}
