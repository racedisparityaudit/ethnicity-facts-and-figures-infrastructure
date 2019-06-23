resource "aws_iam_group_policy_attachment" "all_users_manage_password" {
  group      = "${aws_iam_group.all_users.name}"
  policy_arn = "${data.aws_iam_policy.IAMUserChangePassword.arn}"
}

resource "aws_iam_group_policy_attachment" "all_users_manage_mfa" {
  group      = "${aws_iam_group.all_users.name}"
  policy_arn = "${aws_iam_policy.ManageMFA.arn}"
}
