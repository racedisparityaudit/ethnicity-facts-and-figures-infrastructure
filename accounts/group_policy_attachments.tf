resource "aws_iam_group_policy_attachment" "all_users_manage_password" {
  group      = "${aws_iam_group.all_users.name}"
  policy_arn = "${data.aws_iam_policy.IAMUserChangePassword.arn}"
}

resource "aws_iam_group_policy_attachment" "all_users_manage_mfa" {
  group      = "${aws_iam_group.all_users.name}"
  policy_arn = "${aws_iam_policy.ManageMFA.arn}"
}

resource "aws_iam_group_policy_attachment" "infrastructure_secrets_manager" {
  group      = "${aws_iam_group.infrastructure.name}"
  policy_arn = "${data.aws_iam_policy.SecretsManagerReadWrite.arn}"
}

resource "aws_iam_group_policy_attachment" "infrastructure_s3_full_access" {
  group      = "${aws_iam_group.infrastructure.name}"
  policy_arn = "${data.aws_iam_policy.AmazonS3FullAccess.arn}"
}

resource "aws_iam_group_policy_attachment" "infrastructure_cloudfront_full_access" {
  group      = "${aws_iam_group.infrastructure.name}"
  policy_arn = "${data.aws_iam_policy.CloudFrontFullAccess.arn}"
}

resource "aws_iam_group_policy_attachment" "infrastructure_route53_full_access" {
  group      = "${aws_iam_group.infrastructure.name}"
  policy_arn = "${data.aws_iam_policy.AmazonRoute53FullAccess.arn}"
}
