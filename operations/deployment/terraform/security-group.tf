resource "aws_security_group" "ec2_security_group" {
  name        = var.security_group_name
  description = "SG for ${var.aws_resource_identifier}"
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${var.aws_resource_identifier}-sg"
  }
}


resource "aws_security_group_rule" "ingress_http" {
  type        = "ingress"
  description = "${var.aws_resource_identifier} - Port"
  from_port   = tonumber(var.app_port)
  to_port     = tonumber(var.app_port)
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = aws_security_group.ec2_security_group.id
}

resource "aws_security_group_rule" "ingress_ssh" {
  type        = "ingress"
  description = "SSH"
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = aws_security_group.ec2_security_group.id
}
