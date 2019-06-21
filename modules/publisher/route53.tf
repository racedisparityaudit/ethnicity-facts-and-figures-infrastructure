resource "aws_route53_record" "publisher_cname" {
  zone_id = "${module.domain.root_zone_id}"
  name    = "${var.publisher_subdomain}.${var.domain_name}"
  type    = "CNAME"
  ttl     = 60

  records = [var.publisher_cname]
}
