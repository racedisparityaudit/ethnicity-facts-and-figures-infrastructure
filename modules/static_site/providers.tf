provider "aws" {
  alias   = "frankfurt"
  version = "2.14"
  region  = "eu-central-1"
}

provider "aws" {
  alias   = "ireland"
  version = "2.14"
  region  = "eu-west-1"
}

provider "aws" {
  alias   = "north_virginia"
  version = "2.14"
  region  = "us-east-1"
}
