data "aws_acm_certificate" "issued" {
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

resource "aws_elb" "vm" {
  count              = "${var.sub_domain_name}.${var.domain_name}"  == null ? 0 : 1
  name               = "${var.aws_resource_identifier}"
  security_groups    = [aws_security_group.ec2_security_group.id]
  availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c", "us-east-1d", "us-east-1e", "us-east-1f"]

  access_logs {
    bucket        = aws_s3_bucket.lb_access_logs.id
    interval      = 60
  }

  listener {
    instance_port      = var.app_port
    instance_protocol  = "tcp"
    lb_port            = var.app_port
    lb_protocol        = "ssl"
    ssl_certificate_id = data.aws_acm_certificate.issued.arn
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:${var.app_port}/"
    interval            = 30
  }

  instances                   = [aws_instance.server.id]
  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400

  tags = {
    Name = "${var.aws_resource_identifier}"
  }
}