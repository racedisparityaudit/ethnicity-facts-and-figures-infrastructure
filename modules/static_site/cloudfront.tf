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
    acm_certificate_arn            = "${aws_acm_certificate.static_site.arn}"
    cloudfront_default_certificate = false
    minimum_protocol_version       = "TLSv1.1_2016"
    ssl_support_method             = "sni-only"
  }

  lifecycle {
    prevent_destroy = true
  }
}
