resource "aws_iam_group_membership" "all_users" {
  name  = "all_users"
  group = "${aws_iam_group.all_users.name}"

  users = [
    "${aws_iam_user.sam.name}",
    "${aws_iam_user.frankie.name}"
  ]
}

resource "aws_iam_group_membership" "developers" {
  name  = "developers"
  group = "${aws_iam_group.developers.name}"

  users = [
    "${aws_iam_user.sam.name}",
    "${aws_iam_user.frankie.name}"
  ]
}

resource "aws_iam_group_membership" "infrastructure" {
  name  = "infrastructure"
  group = "${aws_iam_group.infrastructure.name}"

  users = [
    "${aws_iam_user.sam.name}",
    "${aws_iam_user.frankie.name}"
  ]
}
