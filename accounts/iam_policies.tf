data "aws_caller_identity" "current" {}

data "aws_iam_policy" "SecretsManagerReadWrite" {
  arn = "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
}

data "aws_iam_policy" "AmazonS3FullAccess" {
  arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

data "aws_iam_policy" "CloudFrontFullAccess" {
  arn = "arn:aws:iam::aws:policy/CloudFrontFullAccess"
}

data "aws_iam_policy" "IAMUserChangePassword" {
  arn = "arn:aws:iam::aws:policy/IAMUserChangePassword"
}

data "aws_iam_policy" "AmazonRoute53FullAccess" {
  arn = "arn:aws:iam::aws:policy/AmazonRoute53FullAccess"
}

resource "aws_iam_policy" "AssumeRoleInfrastructure" {
  name        = "AssumeRoleInfrastructure"
  description = "Allows users to assume the RDU infrastructure role and make changes to AWS resources."

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "sts:AssumeRole"
        ],
        "Resource" : [
          "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/infrastructure"
        ],
        "Condition" : {
          "Bool" : {
            "aws:MultiFactorAuthPresent" : true
          }
        }
      }
    ]
  })
}

resource "aws_iam_policy" "ManageMFA" {
  name        = "ManageMFA"
  description = "Allow users to manage their own MFA devices"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "AllowViewAccountInfo",
        "Effect" : "Allow",
        "Action" : "iam:ListVirtualMFADevices",
        "Resource" : "*"
      },
      {
        "Sid" : "AllowManageOwnVirtualMFADevice",
        "Effect" : "Allow",
        "Action" : [
          "iam:CreateVirtualMFADevice",
          "iam:DeleteVirtualMFADevice"
        ],
        "Resource" : "arn:aws:iam::*:mfa/$${aws:username}"
      },
      {
        "Sid" : "AllowManageOwnUserMFA",
        "Effect" : "Allow",
        "Action" : [
          "iam:DeactivateMFADevice",
          "iam:EnableMFADevice",
          "iam:GetUser",
          "iam:ListMFADevices",
          "iam:ResyncMFADevice"
        ],
        "Resource" : "arn:aws:iam::*:user/$${aws:username}"
      },
      {
        "Sid" : "DenyAllExceptListedIfNoMFA",
        "Effect" : "Deny",
        "NotAction" : [
          "iam:CreateVirtualMFADevice",
          "iam:EnableMFADevice",
          "iam:GetUser",
          "iam:ListMFADevices",
          "iam:ListVirtualMFADevices",
          "iam:ResyncMFADevice",
          "sts:GetSessionToken"
        ],
        "Resource" : "*",
        "Condition" : {
          "BoolIfExists" : {
            "aws:MultiFactorAuthPresent" : "false"
          }
        }
      }
    ]
  })
}

resource "aws_iam_policy" "DatabaseBackupsWriteOnly" {
  name = "DatabaseBackupsWriteOnly"
  # description = "Allows write-only access to the database backups S3 bucket."

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "DatabaseBackupsWriteOnly",
        "Effect" : "Allow",
        "Action" : [
          "s3:ListAllMyBuckets",
          "s3:ListBucket",
          "s3:PutObject",
          "s3:PutObjectAcl",
          "s3:ListBucketMultipartUploads",
          "s3:ListMultipartUploadParts",
          "s3:AbortMultipartUpload"
        ],
        "Resource" : [
          "arn:aws:s3:::ethnicity-facts-and-figures-db-backups/*"
        ]
      }
    ]
  })
}

resource "aws_iam_policy" "ProductionSiteS3Access" {
  name = "ProductionSiteS3Access"
  # description = "Allows read/write access to production static site S3 buckets."

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "ProductionSiteS3Access",
        "Effect" : "Allow",
        "Action" : "s3:*",
        "Resource" : [
          "arn:aws:s3:::ethinicity-facts-and-figures-production-ireland",
          "arn:aws:s3:::ethinicity-facts-and-figures-production-ireland/*",
          "arn:aws:s3:::ethinicity-facts-and-figures-production-london",
          "arn:aws:s3:::ethinicity-facts-and-figures-production-london/*",
          "arn:aws:s3:::ethnicity-facts-and-figures-production-error-pages",
          "arn:aws:s3:::ethnicity-facts-and-figures-production-error-pages/*",
          "arn:aws:s3:::rd-cms-prod-uploads",
          "arn:aws:s3:::rd-cms-prod-uploads/*"
        ]
      }
    ]
  })
}

resource "aws_iam_policy" "StagingSiteS3Access" {
  name        = "StagingSiteS3Access"
  description = "Access to deploy staging static site and access to cms upload buckets for staging"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "StagingSiteS3Access",
        "Effect" : "Allow",
        "Action" : "s3:*",
        "Resource" : [
          "arn:aws:s3:::ethnicity-facts-and-figures-staging",
          "arn:aws:s3:::rd-cms-staging-uploads",
          "arn:aws:s3:::ethnicity-facts-and-figures-staging-error-pages",
          "arn:aws:s3:::ethnicity-facts-and-figures-staging/*",
          "arn:aws:s3:::rd-cms-staging-uploads/*",
          "arn:aws:s3:::ethnicity-facts-and-figures-staging-error-pages/*"
        ]
      }
    ]
  })
}


resource "aws_iam_policy" "ProductionUploadsReadOnly" {
  name        = "ProductionUploadsReadOnly"
  description = "Allow Staging CMS to read (copy) uploads from the production CMS buckets."

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "ProductionUploadsReadOnly",
        "Effect" : "Allow",
        "Action" : [
          "s3:GetObject",
          "s3:ListBucket"
        ],
        "Resource" : [
          "arn:aws:s3:::rd-cms-prod-uploads",
          "arn:aws:s3:::rd-cms-prod-uploads/*"
        ]
      },
      {
        "Sid" : "VisualEditor1",
        "Effect" : "Allow",
        "Action" : [
          "s3:HeadBucket",
          "s3:ListObjects"
        ],
        "Resource" : "*"
      }
    ]
  })
}
