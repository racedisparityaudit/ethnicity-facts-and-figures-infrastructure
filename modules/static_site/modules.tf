module "domain" {
  source = "../domain"

  domain_name = "${var.domain_name}"
}
