data "aws_route53_zone" "selected" {
  name         = "${var.domain_name}."
  private_zone = false
}

resource "aws_route53_record" "dev" {
  count = "${var.sub_domain_name}.${var.domain_name}" == null ? 0 : 1
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = "${var.sub_domain_name}.${var.domain_name}"
  type    = "A"

  # NOTE: using the array syntax (aws_elb.vm[0]) because the aws_elb is optional via the count property
  #       which causes the properties to exist as a list
  alias {
    name                   = aws_elb.vm[0].dns_name
    zone_id                = aws_elb.vm[0].zone_id
    evaluate_target_health = true
  }
}

output "application_public_dns" {
  description = "Public DNS address for the application behind load balancer"
  value       = "${var.sub_domain_name}.${var.domain_name}"
}