resource "aws_iam_user_policy_attachment" "deploy_static_site_s3_access" {
  user       = "${aws_iam_user.deploy_static_site.name}"
  policy_arn = "${aws_iam_policy.ProductionSiteS3Access.arn}"
}
resource "aws_iam_user_policy_attachment" "production_database_backups" {
  user       = "${aws_iam_user.deploy_static_site.name}"
  policy_arn = "${aws_iam_policy.DatabaseBackupsWriteOnly.arn}"
}

resource "aws_iam_user_policy_attachment" "deploy_static_site_staging_s3_access" {
  user       = "${aws_iam_user.deploy_static_site_staging.name}"
  policy_arn = "${aws_iam_policy.StagingSiteS3Access.arn}"
}

resource "aws_iam_user_policy_attachment" "staging_cms_copy_prod_uplods" {
  user       = "${aws_iam_user.deploy_static_site_staging.name}"
  policy_arn = "${aws_iam_policy.ProductionUploadsReadOnly.arn}"
}
