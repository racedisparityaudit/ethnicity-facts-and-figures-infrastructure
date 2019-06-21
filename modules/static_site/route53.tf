resource "aws_route53_record" "static_site" {
  zone_id = "${module.domain.root_zone_id}"
  name    = "${var.static_site_subdomain}.${var.domain_name}"
  type    = "A"

  alias {
    name                   = "${aws_cloudfront_distribution.cdn.domain_name}"
    zone_id                = "${aws_cloudfront_distribution.cdn.hosted_zone_id}"
    evaluate_target_health = false
  }
}
