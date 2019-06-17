provider "aws" {
  version = "2.14"
  region  = "eu-west-2"
}


terraform {
  required_version = "0.12.2" # Update all other terraform.required_version definitions if you change this.
  backend "s3" {
    bucket = "ethnicity-facts-and-figures-terraform"
    key    = "accounts.tfstate"
    region = "eu-west-2"
  }
}
