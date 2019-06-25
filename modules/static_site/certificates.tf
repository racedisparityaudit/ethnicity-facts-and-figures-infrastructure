resource "aws_acm_certificate" "static_site" {
  provider = aws.north_virginia

  domain_name = "*.ethnicity-facts-figures.service.gov.uk"

  lifecycle {
    create_before_destroy = true
  }
}
