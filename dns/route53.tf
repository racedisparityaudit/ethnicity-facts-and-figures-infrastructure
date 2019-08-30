resource "aws_route53_record" "root_caa" {
  zone_id = "${module.domain.root_zone_id}"
  name    = "${local.domain_name}"
  type    = "CAA"
  ttl     = 300

  records = [
    "0 issue \"letsencrypt.org\"",
    "0 issuewild \"amazontrust.com\"",
    "0 issuewild \"awstrust.com\"",
    "0 issuewild \"amazonaws.com\"",
    "0 issuewild \"amazon.com\""
  ]
}

resource "aws_route53_record" "root_mx" {
  zone_id = "${module.domain.root_zone_id}"
  name    = "${local.domain_name}"
  type    = "MX"
  ttl     = 300

  records = ["10 inbound-smtp.us-east-1.amazonaws.com."]
}

resource "aws_route53_record" "root_ns" {
  zone_id = "${module.domain.root_zone_id}"
  name    = "${local.domain_name}"
  type    = "NS"
  ttl     = 172800

  records = [
    "ns-1175.awsdns-18.org.",
    "ns-798.awsdns-35.net.",
    "ns-1941.awsdns-50.co.uk.",
    "ns-45.awsdns-05.com."
  ]
}

resource "aws_route53_record" "root_soa" {
  zone_id = "${module.domain.root_zone_id}"
  name    = "${local.domain_name}"
  type    = "SOA"
  ttl     = 900

  records = [
    "ns-1941.awsdns-50.co.uk. awsdns-hostmaster.amazon.com. 1 7200 900 1209600 86400",
  ]
}

resource "aws_route53_record" "root_txt" {
  zone_id = "${module.domain.root_zone_id}"
  name    = "${local.domain_name}"
  type    = "TXT"
  ttl     = 86400

  records = ["v=spf1 include:mailgun.org include:amazonses.com ~all"]
}

resource "aws_route53_record" "root_amazonses" {
  zone_id = "${module.domain.root_zone_id}"
  name    = "_amazonses.${local.domain_name}"
  type    = "TXT"
  ttl     = 1800

  records = [
    "NGjEenKmQPwEiE7+p6J4j23S1ek1i0u/RLbBbGSHmDE=",
    "0bJ2zk9FUUmLHV7fHj1xH/tAmwSzLz99esJRgG8PFFw="
  ]
}

resource "aws_route53_record" "root_dmarc" {
  zone_id = "${module.domain.root_zone_id}"
  name    = "_dmarc.${local.domain_name}"
  type    = "TXT"
  ttl     = 600

  records = [
    "v=DMARC1; p=reject; sp=reject; rua=mailto:developers@ethnicity-facts-figures.service.gov.uk!10m; ruf=mailto:developers@ethnicity-facts-figures.service.gov.uk!10m; rf=afrf; pct=100; ri=86400"
  ]
}

resource "aws_route53_record" "mail_mx" {
  zone_id = "${module.domain.root_zone_id}"
  name    = "mail.${local.domain_name}"
  type    = "MX"
  ttl     = 300

  records = [
    "10 mxa.mailgun.org",
    "10 mxb.mailgun.org"
  ]
}

resource "aws_route53_record" "mail_txt" {
  zone_id = "${module.domain.root_zone_id}"
  name    = "mail.${local.domain_name}"
  type    = "TXT"
  ttl     = 300

  records = ["v=spf1 include:mailgun.org ~all"]
}

resource "aws_route53_record" "mail_dmarc" {
  zone_id = "${module.domain.root_zone_id}"
  name    = "_dmarc.mail.${local.domain_name}"
  type    = "TXT"
  ttl     = 300

  records = ["v=DMARC1; p=reject; rua=mailto:developers@ethnicity-facts-figures.service.gov.uk!10m; ruf=mailto:developers@ethnicity-facts-figures.service.gov.uk!10m; pct=100;"]
}

resource "aws_route53_record" "mailgun_root_domainkey_txt" {
  zone_id = "${module.domain.root_zone_id}"
  name    = "mailo._domainkey.mail.${local.domain_name}"
  type    = "TXT"
  ttl     = 300

  records = ["k=rsa; p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDwE+Fnn4XbcigR32eXlaLdyIspOzuCQBj7fhTayR/oc3f3hzuFBIK6GR6yTiOutlfZhH7tLt97Fp8tcetg5zx9BY9UK1AkbhYJkKWjh3ySUx5d2ejbuDo6FYIucuBCu417y0i1yzEeTQ0pbkTDN82+VMWMFriEHJ0ZLp4ZTWDJLQIDAQAB"]
}

resource "aws_route53_record" "developer_docs_cname" {
  zone_id = "${module.domain.root_zone_id}"
  name    = "developers.${local.domain_name}"
  type    = "CNAME"
  ttl     = 300

  records = ["mysterious-tortoise-28ahl9o8t04rfn1hfc6vmpii.herokudns.com"]
}

resource "aws_route53_record" "style_guide_cname" {
  zone_id = "${module.domain.root_zone_id}"
  name    = "guide.${local.domain_name}"
  type    = "CNAME"
  ttl     = 300

  records = ["racedisparityaudit.github.io"]
}

resource "aws_route53_record" "root_domainkey_cname" {
  count = length(local.domainkeys)

  zone_id = "${module.domain.root_zone_id}"
  name    = "${local.domainkeys[count.index]}._domainkey.${local.domain_name}"
  type    = "CNAME"
  ttl     = 300

  records = ["${local.domainkeys[count.index]}.dkim.amazonses.com"]
}

resource "aws_route53_record" "workmail_autodiscover_cname" {
  zone_id = "${module.domain.root_zone_id}"
  name    = "autodiscover.${local.domain_name}"
  type    = "CNAME"
  ttl     = 300

  records = ["autodiscover.mail.us-east-1.awsapps.com."]
}
