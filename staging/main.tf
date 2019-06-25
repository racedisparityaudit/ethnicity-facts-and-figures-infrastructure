provider "aws" {
  version = "2.14"
  region  = "eu-west-2"
}

provider "aws" {
  alias   = "ireland"
  version = "2.14"
  region  = "eu-west-1"
}

provider "aws" {
  alias   = "frankfurt"
  version = "2.14"
  region  = "eu-central-1"
}

provider "aws" {
  alias   = "north_virginia"
  version = "2.14"
  region  = "us-east-1"
}

terraform {
  required_version = "0.12.2" # Update all other terraform.required_version definitions if you change this.
  backend "s3" {
    bucket = "ethnicity-facts-and-figures-terraform"
    key    = "staging.tfstate"
    region = "eu-west-2"
  }
}

data "aws_caller_identity" "current" {}

locals {
  domain_name = "ethnicity-facts-figures.service.gov.uk."
}

module "domain" {
  source = "../modules/domain"

  domain_name = "${local.domain_name}"
}

module "static_site" {
  source = "../modules/static_site"

  environment        = "staging"
  static_site_bucket = "ethnicity-facts-and-figures-staging"
  error_pages_bucket = "ethnicity-facts-and-figures-staging-error-pages"
  uploads_bucket     = "rd-cms-staging-uploads"
  static_site_url    = "staging.ethnicity-facts-figures.service.gov.uk"
  cloudfront_lambdas = ["arn:aws:lambda:us-east-1:${data.aws_caller_identity.current.account_id}:function:httpBasicAuth:12"]

  domain_name           = "ethnicity-facts-figures.service.gov.uk."
  static_site_subdomain = "staging"
}
