resource "aws_iam_user" "sam" {
  name          = "sam"
  force_destroy = false
}

resource "aws_iam_user" "frankie" {
  name          = "frankie"
  force_destroy = false
}

resource "aws_iam_user" "deploy_static_site" {
  name          = "deploy_static_site"
  force_destroy = false
}

resource "aws_iam_user" "deploy_static_site_staging" {
  name          = "deploy_static_site_staging"
  force_destroy = false
}
