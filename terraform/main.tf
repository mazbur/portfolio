provider "aws" {
  region = var.aws_region
}

# ACM certificates for CloudFront must be in us-east-1
provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}

# Reads the API token from the CLOUDFLARE_API_TOKEN environment variable.
# Deliberately not a Terraform variable, so the token cannot end up in
# terraform.tfvars or the state file.
provider "cloudflare" {}

locals {
  bucket_name = "${var.project_name}-${replace(var.domain_name, ".", "-")}"
  common_tags = {
    Project   = var.project_name
    ManagedBy = "terraform"
  }
}
