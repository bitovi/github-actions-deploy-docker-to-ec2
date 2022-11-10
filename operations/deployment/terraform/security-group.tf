resource "aws_security_group" "ec2_security_group" {
  name        = var.security_group_name
  description = "SG for ${var.ops_repo_environment}"
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${var.ops_repo_environment}-sg"
  }
}


resource "aws_security_group_rule" "ingress_http" {
  type        = "ingress"
  description = "Jira-Ops-Port"
  from_port   = local.environment.PORT
  to_port     = local.environment.PORT
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
