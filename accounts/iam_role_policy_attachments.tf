resource "aws_iam_role_policy_attachment" "infrastructure_role_lambda_full_access" {
  role       = "${aws_iam_role.infrastructure.name}"
  policy_arn = "${data.aws_iam_policy.AWSLambdaFullAccess.arn}"
}

resource "aws_iam_role_policy_attachment" "infrastructure_role_iam_full_access" {
  role       = "${aws_iam_role.infrastructure.name}"
  policy_arn = "${data.aws_iam_policy.IAMFullAccess.arn}"
}

resource "aws_iam_role_policy_attachment" "infrastructure_role_s3_full_access" {
  role       = "${aws_iam_role.infrastructure.name}"
  policy_arn = "${data.aws_iam_policy.AmazonS3FullAccess.arn}"
}

resource "aws_iam_role_policy_attachment" "infrastructure_role_cloudfront_full_access" {
  role       = "${aws_iam_role.infrastructure.name}"
  policy_arn = "${data.aws_iam_policy.CloudFrontFullAccess.arn}"
}

resource "aws_iam_role_policy_attachment" "infrastructure_role_route53_full_access" {
  role       = "${aws_iam_role.infrastructure.name}"
  policy_arn = "${data.aws_iam_policy.AmazonRoute53FullAccess.arn}"
}

resource "aws_iam_role_policy_attachment" "infrastructure_role_acm_full_access" {
  role       = "${aws_iam_role.infrastructure.name}"
  policy_arn = "${data.aws_iam_policy.AWSCertificateManagerFullAccess.arn}"
}

resource "aws_iam_role_policy_attachment" "infrastructure_role_workmail_full_access" {
  role       = "${aws_iam_role.infrastructure.name}"
  policy_arn = "${data.aws_iam_policy.AmazonWorkMailFullAccess.arn}"
}

resource "aws_iam_role_policy_attachment" "infrastructure_role_cloudtrail_full_access" {
  role       = "${aws_iam_role.infrastructure.name}"
  policy_arn = "${data.aws_iam_policy.AWSCloudTrailFullAccess.arn}"
}

resource "aws_iam_role_policy_attachment" "infrastructure_role_guardduty_full_access" {
  role       = "${aws_iam_role.infrastructure.name}"
  policy_arn = "${data.aws_iam_policy.AmazonGuardDutyFullAccess.arn}"
}
