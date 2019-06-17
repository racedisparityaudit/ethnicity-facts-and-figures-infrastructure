data "aws_caller_identity" "current" {}

provider "aws" {
  alias   = "frankfurt"
  version = "2.14"
  region  = "eu-central-1"
}

provider "aws" {
  alias   = "ireland"
  version = "2.14"
  region  = "eu-west-1"
}

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

resource "aws_cloudfront_distribution" "cdn" {
  aliases             = ["${var.static_site_url}"]
  comment             = "${title(var.environment)} www site"
  default_root_object = "index.html"
  enabled             = true
  is_ipv6_enabled     = true
  retain_on_delete    = false
  price_class         = "PriceClass_100"

  custom_error_response {
    error_caching_min_ttl = 300
    error_code            = 403
    response_code         = 403
    response_page_path    = "/major-errors/403.html"
  }

  custom_error_response {
    error_caching_min_ttl = 300
    error_code            = 404
    response_code         = 404
    response_page_path    = "/major-errors/404.html"
  }

  default_cache_behavior {
    allowed_methods = [
      "GET",
      "HEAD",
    ]
    cached_methods = [
      "GET",
      "HEAD",
    ]
    compress               = true
    default_ttl            = 86400
    max_ttl                = 31536000
    min_ttl                = 0
    smooth_streaming       = false
    target_origin_id       = "S3-${var.static_site_bucket}"
    trusted_signers        = []
    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      headers                 = []
      query_string            = true
      query_string_cache_keys = []

      cookies {
        forward           = "none"
        whitelisted_names = []
      }
    }

    dynamic "lambda_function_association" {
      for_each = [for lambda in var.cloudfront_lambdas : { uri = lambda }]

      content {
        event_type   = "viewer-request"
        include_body = false
        lambda_arn   = lambda_function_association.value.uri
      }
    }
  }

  dynamic "logging_config" {
    for_each = concat(
      var.cloudfront_logs != "" ? ["${var.cloudfront_logs}"] : []
    )

    content {
      bucket          = "${logging_config.value}.s3.amazonaws.com"
      include_cookies = false
      prefix          = "cloudfront-s3-www-${var.environment}-london"
    }
  }

  ordered_cache_behavior {
    allowed_methods = [
      "GET",
      "HEAD",
    ]
    cached_methods = [
      "GET",
      "HEAD",
    ]
    compress               = false
    default_ttl            = 300
    max_ttl                = 300
    min_ttl                = 0
    path_pattern           = "/major-errors/*.html"
    smooth_streaming       = false
    target_origin_id       = "S3-${var.error_pages_bucket}"
    trusted_signers        = []
    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      headers                 = []
      query_string            = false
      query_string_cache_keys = []

      cookies {
        forward           = "none"
        whitelisted_names = []
      }
    }
  }

  dynamic "origin" {
    for_each = concat(
      ["${var.static_site_bucket}"],
      var.static_site_follower_bucket != "" ? ["${var.static_site_follower_bucket}"] : [],
    )

    content {
      domain_name = "${origin.value}.s3-website.eu-west-2.amazonaws.com"
      origin_id   = "S3-${origin.value}"

      custom_header {
        name  = "X-Content-Type-Options"
        value = "nosniff"
      }
      custom_header {
        name  = "X-Frame-Options"
        value = "deny"
      }
      custom_header {
        name  = "X-Xss-Protection"
        value = "1; mode=block"
      }

      custom_origin_config {
        http_port                = 80
        https_port               = 443
        origin_keepalive_timeout = 5
        origin_protocol_policy   = "http-only"
        origin_read_timeout      = 30
        origin_ssl_protocols = [
          "TLSv1",
          "TLSv1.1",
          "TLSv1.2",
        ]
      }
    }
  }

  origin {
    domain_name = "${var.error_pages_bucket}.s3.amazonaws.com"
    origin_id   = "S3-${var.error_pages_bucket}"
  }

  restrictions {
    geo_restriction {
      locations        = []
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn            = "arn:aws:acm:us-east-1:${data.aws_caller_identity.current.account_id}:certificate/e70bf737-89e3-4085-bf4c-c269e64c8477" # TODO: import and manage this certificate in code
    cloudfront_default_certificate = false
    minimum_protocol_version       = "TLSv1.1_2016"
    ssl_support_method             = "sni-only"
  }

  lifecycle {
    prevent_destroy = true
  }
}
