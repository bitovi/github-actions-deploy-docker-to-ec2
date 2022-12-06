data "aws_acm_certificate" "issued" {
  count = local.fqdn_provided ? 1 : 0
  domain = var.domain_name
}

data "aws_elb_service_account" "main" {}
resource "aws_s3_bucket" "lb_access_logs" {
  bucket = var.lb_access_bucket_name

  policy = <<POLICY
{
  "Id": "Policy",
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:PutObject"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::${var.lb_access_bucket_name}/*",
      "Principal": {
        "AWS": [
          "${data.aws_elb_service_account.main.arn}"
        ]
      }
    }
  ]
}
POLICY

  tags = {
    Name  = var.lb_access_bucket_name
  }
}

resource "aws_s3_bucket_acl" "lb_access_logs_acl" {
  bucket = aws_s3_bucket.lb_access_logs.id
  acl    = "private"
}

resource "aws_elb" "vm_ssl" {
  count              = local.fqdn_provided ? 1 : 0
  name               = "${var.aws_resource_identifier_supershort}"
  security_groups    = [aws_security_group.ec2_security_group.id]
  availability_zones = [aws_instance.server.availability_zone]

  access_logs {
    bucket        = aws_s3_bucket.lb_access_logs.id
    interval      = 60
  }

  listener {
    instance_port      = var.app_port
    instance_protocol  = "tcp"
    lb_port            = var.lb_port != "" ? var.lb_port : 443
    lb_protocol        = "ssl"
    ssl_certificate_id = data.aws_acm_certificate.issued[0].arn
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = var.lb_healthcheck != "" ? var.lb_healthcheck : "HTTP:${var.app_port}/"
    interval            = 30
  }

  instances                   = [aws_instance.server.id]
  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400

  tags = {
    Name = "${var.aws_resource_identifier_supershort}"
  }
}

resource "aws_elb" "vm" {
  count              = local.fqdn_provided ? 0 : 1
  name               = "${var.aws_resource_identifier_supershort}"
  security_groups    = [aws_security_group.ec2_security_group.id]
  availability_zones = [aws_instance.server.availability_zone]

  access_logs {
    bucket        = aws_s3_bucket.lb_access_logs.id
    interval      = 60
  }

  listener {
    instance_port      = var.app_port
    instance_protocol  = "tcp"
    lb_port            = var.lb_port != "" ? var.lb_port : 80
    lb_protocol        = "tcp"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = var.lb_healthcheck != "" ? var.lb_healthcheck : "HTTP:${var.app_port}/"
    interval            = 30
  }

  instances                   = [aws_instance.server.id]
  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400

  tags = {
    Name = "${var.aws_resource_identifier_supershort}"
  }
}

output "lb_public_dns" {
  description = "Public DNS address of the LB"
  value       = "${ local.fqdn_provided ? aws_elb.vm_ssl[0].dns_name : aws_elb.vm[0].dns_name }"
}
