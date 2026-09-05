terraform {
  required_version = ">= 1.9"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5.0"
    }
  }

 backend "s3" {
  bucket       = "portfolio-tfstate-382071074463"
  key          = "portfolio/terraform.tfstate"
  region       = "us-east-1"
  encrypt      = true
  use_lockfile = true
 }
}
