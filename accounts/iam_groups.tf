resource "aws_iam_group" "all_users" {
  name = "all_users"
}

resource "aws_iam_group" "developers" {
  name = "developers"
}

resource "aws_iam_group" "infrastructure" {
  name = "infrastructure"
}
