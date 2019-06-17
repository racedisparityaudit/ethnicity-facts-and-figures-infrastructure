provider "aws" {
  version = "2.14"
  region  = "eu-west-2"
}

terraform {
  required_version = "0.12.2" # Update all other terraform.required_version definitions if you change this.
  backend "s3" {
    bucket = "ethnicity-facts-and-figures-terraform"
    key    = "backups.tfstate"
    region = "eu-west-2"
  }
}

resource "aws_s3_bucket" "backups" {
  bucket        = "ethnicity-facts-and-figures-db-backups"
  acl           = "private"
  force_destroy = false

  versioning {
    enabled    = true
    mfa_delete = false
  }

  logging {
    target_bucket = "ethinicity-facts-and-figures-logs-london" # sic
    target_prefix = "ethnicity-facts-and-figures-db-backups/"
  }

  lifecycle_rule {
    id      = "expire_current_versions"
    enabled = true

    expiration {
      days = 1098
    }
  }

  lifecycle_rule {
    id      = "expire_previous_versions"
    enabled = true

    noncurrent_version_expiration {
      days = 1098
    }
  }
}
