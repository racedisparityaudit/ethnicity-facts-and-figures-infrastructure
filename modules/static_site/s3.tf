resource "aws_s3_bucket" "static_site" {
  bucket        = "${var.static_site_bucket}"
  acl           = "public-read"
  force_destroy = false

  versioning {
    enabled    = true
    mfa_delete = false
  }

  logging {
    target_bucket = "${var.logging_bucket}-london"
    target_prefix = "${var.static_site_bucket}/"
  }

  website { # Not managed by terraform as it would override the routing rules for redirects
    index_document = "index.html"
    routing_rules  = ""
  }

  lifecycle {
    ignore_changes = ["website"]
  }

  dynamic "replication_configuration" {
    for_each = concat(
      var.static_site_follower_bucket != "" ? ["${var.static_site_follower_bucket}"] : []
    )

    content {
      role = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/service-role/replication_role_for_ethinicity-facts-and-figures-production-lon" # TODO: import and manage this role in code

      rules {
        id       = "ethinicity-facts-and-figures-production-london"
        priority = 0
        status   = "Enabled"

        destination {
          bucket = "arn:aws:s3:::${var.static_site_follower_bucket}"
        }
      }
    }
  }
}

resource "aws_s3_bucket" "static_site_follower" {
  provider = aws.ireland
  count    = "${var.static_site_follower_bucket != "" ? 1 : 0}"

  bucket        = "${var.static_site_follower_bucket}"
  acl           = "public-read"
  force_destroy = false

  versioning {
    enabled    = true
    mfa_delete = false
  }

  logging {
    target_bucket = "${var.logging_bucket}-ireland"
    target_prefix = "${var.static_site_follower_bucket}/"
  }

  website { # Not managed by terraform as it would override the routing rules for redirects
    index_document = "index.html"
    routing_rules  = ""
  }

  lifecycle {
    ignore_changes = ["website"]
  }
}


resource "aws_s3_bucket_policy" "static_site" {
  bucket = "${var.static_site_bucket}"
  policy = jsonencode(
    {
      Id = "StaticSitePolicy"
      Statement = [
        {
          "Sid" : "allow-everyone-read-objects",
          "Effect" : "Allow",
          "Principal" : "*",
          "Action" : "s3:GetObject",
          "Resource" : "arn:aws:s3:::${var.static_site_bucket}/*"
        }
      ]
      Version = "2008-10-17"
    }
  )
}


resource "aws_s3_bucket_policy" "static_site_follower" {
  provider = aws.ireland
  count    = "${var.static_site_follower_bucket != "" ? 1 : 0}"

  bucket = "${var.static_site_follower_bucket}"
  policy = jsonencode(
    {
      Id = "StaticSitePolicy"
      Statement = [
        {
          "Sid" : "allow-everyone-read-objects",
          "Effect" : "Allow",
          "Principal" : "*",
          "Action" : "s3:GetObject",
          "Resource" : "arn:aws:s3:::${var.static_site_follower_bucket}/*"
        }
      ]
      Version = "2008-10-17"
    }
  )
}

resource "aws_s3_bucket" "error_pages" {
  provider      = aws.frankfurt
  bucket        = "${var.error_pages_bucket}"
  acl           = "private"
  force_destroy = false

  logging {
    target_bucket = "${var.logging_bucket}-frankfurt"
    target_prefix = "${var.error_pages_bucket}/"
  }

  versioning {
    enabled    = true
    mfa_delete = false
  }
}

resource "aws_s3_bucket_policy" "error_pages" {
  provider = aws.frankfurt
  bucket   = "${var.error_pages_bucket}"

  policy = jsonencode(
    {
      Id = "ErrorPagesPolicy"
      Statement = [
        {
          Action    = "s3:GetObject"
          Effect    = "Allow"
          Principal = "*"
          Resource  = "arn:aws:s3:::${var.error_pages_bucket}/*"
          Sid       = "allow-everyone-read-objects"
        },
      ]
      Version = "2012-10-17"
    }
  )
}

resource "aws_s3_bucket" "uploads" {
  bucket        = "${var.uploads_bucket}"
  acl           = "private"
  force_destroy = false

  versioning {
    enabled    = false
    mfa_delete = false
  }
}

resource "aws_s3_bucket_public_access_block" "uploads" {
  bucket = "${var.uploads_bucket}"

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
