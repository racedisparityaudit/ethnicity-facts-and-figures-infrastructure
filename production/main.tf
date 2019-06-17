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

terraform {
  required_version = "0.12.2" # Update all other terraform.required_version definitions if you change this.
  backend "s3" {
    bucket = "ethnicity-facts-and-figures-terraform"
    key    = "production.tfstate"
    region = "eu-west-2"
  }
}

module "static_site" {
  source = "../modules/static_site"

  environment                 = "prod"
  static_site_bucket          = "ethinicity-facts-and-figures-production-london"
  static_site_follower_bucket = "ethinicity-facts-and-figures-production-ireland"
  error_pages_bucket          = "ethnicity-facts-and-figures-production-error-pages"
  uploads_bucket              = "rd-cms-prod-uploads"
  static_site_url             = "www.ethnicity-facts-figures.service.gov.uk"
  cloudfront_lambdas          = []
  cloudfront_logs             = "ethinicity-facts-and-figures-logs-frankfurt"
}
