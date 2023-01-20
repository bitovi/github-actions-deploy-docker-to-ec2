# Lookup for main domain.

data "aws_acm_certificate" "issued" {
  count  = var.no_cert == "true" ? 0 : (var.create_root_cert != "true" ? (var.create_sub_cert != "true" ? (local.fqdn_provided ? 1 : 0) : 0) : 0)
  domain = var.domain_name
}

# This block will create and validate the root domain and www cert
resource "aws_acm_certificate" "root_domain" {
  count                     = var.create_root_cert == "true" ? (var.domain_name != "" ? 1 : 0) : 0
  domain_name               = var.domain_name
  subject_alternative_names = ["*.${var.domain_name}", "${var.domain_name}"]
  validation_method         = "DNS"
}

resource "aws_route53_record" "root_domain" {
  count           = var.create_root_cert == "true" ? (var.domain_name != "" ? 1 : 0) : 0
  allow_overwrite = true
  name            = tolist(aws_acm_certificate.root_domain[0].domain_validation_options)[0].resource_record_name
  records         = [tolist(aws_acm_certificate.root_domain[0].domain_validation_options)[0].resource_record_value]
  type            = tolist(aws_acm_certificate.root_domain[0].domain_validation_options)[0].resource_record_type
  zone_id         = data.aws_route53_zone.selected[0].zone_id
  ttl             = 60
}

resource "aws_acm_certificate_validation" "root_domain" {
  count                   = var.create_root_cert == "true" ? (var.domain_name != "" ? 1 : 0) : 0
  certificate_arn         = aws_acm_certificate.root_domain[0].arn
  validation_record_fqdns = [for record in aws_route53_record.root_domain : record.fqdn]
}


# This block will create and validate the sub domain cert ONLY
resource "aws_acm_certificate" "sub_domain" {
  count             = var.create_sub_cert == "true" ? (var.domain_name != "" ? (var.sub_domain_name != "" ? 1 : 0) : 0) : 0
  domain_name       = "${var.sub_domain_name}.${var.domain_name}"
  validation_method = "DNS"
}

resource "aws_route53_record" "sub_domain" {
  count           = var.create_sub_cert == "true" ? (var.domain_name != "" ? (var.sub_domain_name != "" ? 1 : 0) : 0) : 0
  allow_overwrite = true
  name            = tolist(aws_acm_certificate.sub_domain[0].domain_validation_options)[0].resource_record_name
  records         = [tolist(aws_acm_certificate.sub_domain[0].domain_validation_options)[0].resource_record_value]
  type            = tolist(aws_acm_certificate.sub_domain[0].domain_validation_options)[0].resource_record_type
  zone_id         = data.aws_route53_zone.selected[0].zone_id
  ttl             = 60
}

resource "aws_acm_certificate_validation" "sub_domain" {
  count                   = var.create_sub_cert == "true" ? (var.domain_name != "" ? 1 : 0) : 0
  certificate_arn         = aws_acm_certificate.sub_domain[0].arn
  validation_record_fqdns = [for record in aws_route53_record.sub_domain : record.fqdn]
}

locals {
  selected_arn = (
    var.no_cert == "true" ? "" :
    (var.cert_arn != "" ? var.cert_arn :
      (var.create_root_cert != "true" ?
        (var.create_sub_cert != "true" ?
          (local.fqdn_provided ? data.aws_acm_certificate.issued[0].arn : "")
          : aws_acm_certificate.sub_domain[0].arn
        ) : aws_acm_certificate.root_domain[0].arn
      )
    )
  )
  cert_available = (
    var.no_cert == "true" ? false :
    (var.cert_arn != "" ? true :
      (var.create_root_cert != "true" ?
        (var.create_sub_cert != "true" ?
          (local.fqdn_provided ? true : false)
          : true
        ) : true
      )
    )
  )
}

output "selected_arn" {
  value = local.selected_arn
}