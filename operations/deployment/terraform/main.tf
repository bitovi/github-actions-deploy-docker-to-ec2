resource "tls_private_key" "key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

// Creates an ec2 key pair using the tls_private_key.key public key
resource "aws_key_pair" "aws_key" {
  key_name   = "${var.aws_resource_identifier_supershort}-ec2kp-${random_string.random.result}"
  public_key = tls_private_key.key.public_key_openssh
}

// Creates a secret manager secret for the public key
resource "aws_secretsmanager_secret" "keys_sm_secret" {
  count              = var.create_keypair_sm_entry ? 1 : 0
  name   = "${var.aws_resource_identifier_supershort}-sm-${random_string.random.result}"
}
 
resource "aws_secretsmanager_secret_version" "keys_sm_secret_version" {
  count     = var.create_keypair_sm_entry ? 1 : 0
  secret_id = aws_secretsmanager_secret.keys_sm_secret[0].id
  secret_string = <<EOF
   {
    "key": "public_key",
    "value": "${sensitive(tls_private_key.key.public_key_openssh)}"
   },
   {
    "key": "private_key",
    "value": "${sensitive(tls_private_key.key.private_key_openssh)}"
   }
EOF
}

resource "random_string" "random" {
  length    = 5
  lower     = true
  special   = false
  numeric   = false
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = var.aws_resource_identifier
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
  availability_zone           = local.preferred_az
  subnet_id                   = data.aws_subnet.selected[0].id
  instance_type               = var.ec2_instance_type
  associate_public_ip_address = var.ec2_instance_public_ip
  vpc_security_group_ids      = [aws_security_group.ec2_security_group.id]
  key_name                    = aws_key_pair.aws_key.key_name
  monitoring                  = true
  iam_instance_profile        = aws_iam_instance_profile.ec2_profile.name
  root_block_device {
    volume_size = tonumber(var.ec2_volume_size)
  }
  tags = {
    Name = "${var.aws_resource_identifier} - Instance"
  }
}

data "aws_instance" "server" {
  filter {
    name   = "dns-name"
    values = [aws_instance.server.public_dns]
  }
}

output "instance_public_dns" {
  description = "Public DNS address of the EC2 instance"
  value       = var.ec2_instance_public_ip ? aws_instance.server.public_dns : "EC2 Instance doesn't have public DNS"
}
