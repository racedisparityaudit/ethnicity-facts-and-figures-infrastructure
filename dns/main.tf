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
  required_version = "0.12.8" # Update all other terraform.required_version definitions if you change this.
  backend "s3" {
    bucket = "ethnicity-facts-and-figures-terraform"
    key    = "mail.tfstate"
    region = "eu-west-2"
  }
}

locals {
  domain_name = "ethnicity-facts-figures.service.gov.uk."
  domainkeys = [
    "3iteakr5qqj655npmsdscmupyl332vsp",
    "bug5p4t3ma46j2unggorv4psh4y5i6me",
    "gw4fu47afuy7xwgeon2lwl545cmbnk45",
    "wme2z6ab7xbcktnvcjy55o2k6j3eypby",
    "xcx545y36yswnb4p7yblqesoh26al4xx",
    "yrt63snf7u5u2ll2xdeif37i3zwdltlg"
  ]
}

module "domain" {
  source = "../modules/domain"

  domain_name = "${local.domain_name}"
}
