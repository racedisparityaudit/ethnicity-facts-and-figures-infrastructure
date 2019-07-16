resource "aws_iam_access_key" "security_auditor" {
  user = "${aws_iam_user.security_auditor.name}"
}
