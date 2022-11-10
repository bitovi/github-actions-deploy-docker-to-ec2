resource "tls_private_key" "key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "aws_key" {
  key_name   = "${var.ops_repo_environment}-ssh-key"
  public_key = tls_private_key.key.public_key_openssh
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.ops_repo_environment}-profile"
  role = var.ec2_iam_instance_profile
}

resource "aws_instance" "server" {
  # ubuntu
  ami                         = "ami-052efd3df9dad4825"
  instance_type               = var.ec2_instance_type
  associate_public_ip_address = true
  security_groups             = [aws_security_group.ec2_security_group.name]
  key_name                    = aws_key_pair.aws_key.key_name
  monitoring                  = true
  iam_instance_profile        = aws_iam_instance_profile.ec2_profile.name

  tags = {
   Name = "${var.ops_repo_environment} - Instance"
  }
}

