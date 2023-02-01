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

data "aws_ami" "ubuntu" {
 most_recent = true
 filter {
   name   = "name"
   values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
 }
 filter {
   name   = "virtualization-type"
   values = ["hvm"]
 }
 owners = ["099720109477"]
}

resource "aws_instance" "server" {
  # ubuntu
  ami                         = var.aws_ami_id != "" ? var.aws_ami_id : data.aws_ami.ubuntu.id
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

data "aws_instance" "server" {
  filter {
    name   = "dns-name"
    values = [ aws_instance.server.public_dns ]
  }
}

output "instance_public_dns" {
  description = "Public DNS address of the EC2 instance"
  value       = var.ec2_instance_public_ip ? aws_instance.server.public_dns : "EC2 Instance doesn't have public DNS"
}
