
resource "aws_iam_user" "frankie" {
  name          = "frankie"
  force_destroy = true # Required to destroy users where MFA/other resources aren't managed by terraform - like us
}

resource "aws_iam_user" "mehmet" {
  name          = "mehmet"
  force_destroy = true # Required to destroy users where MFA/other resources aren't managed by terraform - like us
}

resource "aws_iam_user" "deploy_static_site" {
  name          = "deploy_static_site"
  force_destroy = false
}

resource "aws_iam_user" "deploy_static_site_staging" {
  name          = "deploy_static_site_staging"
  force_destroy = false
}
