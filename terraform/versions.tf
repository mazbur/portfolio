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

  # Optional: store state remotely. The bucket must already exist — Terraform
  # cannot create the bucket that holds its own state, so see "Optional: remote
  # state" in SETUP.md for the one-time bootstrap.
  #
  # `use_lockfile` is S3-native locking and needs Terraform >= 1.11. It replaces
  # the old `dynamodb_table` argument, which HashiCorp has deprecated and will
  # remove in a future minor version — no lock table is needed any more.
  #
  # backend "s3" {
  #   bucket       = "your-tfstate-bucket"
  #   key          = "portfolio/terraform.tfstate"
  #   region       = "us-east-1"
  #   encrypt      = true
  #   use_lockfile = true
  # }
}
