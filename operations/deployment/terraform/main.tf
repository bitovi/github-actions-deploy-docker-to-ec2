resource "tls_private_key" "key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "aws_key" {
  key_name   = "${var.aws_resource_identifier}"
  public_key = tls_private_key.key.public_key_openssh
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.aws_resource_identifier}"
  role = aws_iam_role.ec2_role.name
}

resource "aws_instance" "server" {
  # ubuntu
  ami                         = "ami-052efd3df9dad4825"
  instance_type               = var.ec2_instance_type
  associate_public_ip_address = var.ec2_instance_public_ip
  security_groups             = [aws_security_group.ec2_security_group.name]
  key_name                    = aws_key_pair.aws_key.key_name
  monitoring                  = true
  iam_instance_profile        = aws_iam_instance_profile.ec2_profile.name

  tags = {
   Name = "${var.aws_resource_identifier} - Instance"
  }
}

output "instance_public_dns" {
  count       = var.ec2_instance_public_ip ? 1 : 0
  description = "Public DNS address of the EC2 instance"
  value       = aws_instance.server.public_dns
}

