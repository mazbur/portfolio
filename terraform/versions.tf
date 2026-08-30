terraform {
  required_version = ">= 1.9"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }

    # v5 renamed cloudflare_record -> cloudflare_dns_record and switched
    # `value` to `content`; the config here uses the v5 schema.
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5.0"
    }
  }

  # Uncomment and configure to store state remotely (recommended)
  # backend "s3" {
  #   bucket         = "your-tfstate-bucket"
  #   key            = "portfolio/terraform.tfstate"
  #   region         = "us-east-1"
  #   dynamodb_table = "your-tfstate-lock"
  #   encrypt        = true
  # }
}
