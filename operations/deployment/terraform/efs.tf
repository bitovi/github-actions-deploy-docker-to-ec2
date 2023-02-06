locals {
  no_zone_mapping  = { "" : { "subnet_id" : "", "security_groups" : [""] } }
  ec2_zone_mapping = { "${data.aws_instance.server.availability_zone}" : { "subnet_id" : "${data.aws_instance.server.subnet_id}", "security_groups" : ["${data.aws_security_group.ec2_security_group.id}"] } }

  auto_ha_availability_zonea = {
    "${data.aws_region.current.name}a" : {
      "subnet_id" : data.aws_subnet.defaulta.id,
      "security_groups" : [data.aws_security_group.default.id]
  } }
  auto_ha_availability_zoneb = length(data.aws_subnet.defaultb) > 0 ? ({
    "${data.aws_region.current.name}b" : {
      "subnet_id" : data.aws_subnet.defaultb[0].id,
      "security_groups" : [data.aws_security_group.default.id]
    }
  }) : null
  auto_ha_availability_zonec = length(data.aws_subnet.defaultc) > 0 ? ({
    "${data.aws_region.current.name}c" : {
      "subnet_id" : data.aws_subnet.defaultc[0].id,
      "security_groups" : [data.aws_security_group.default.id]
    }
  }) : null
  auto_ha_availability_zoned = length(data.aws_subnet.defaultd) > 0 ? ({
    "${data.aws_region.current.name}d" : {
      "subnet_id" : data.aws_subnet.defaultd[0].id,
      "security_groups" : [data.aws_security_group.default.id]
    }
  }) : null
  auto_ha_availability_zonee = length(data.aws_subnet.defaulte) > 0 ? ({
    "${data.aws_region.current.name}e" : {
      "subnet_id" : data.aws_subnet.defaulte[0].id,
      "security_groups" : [data.aws_security_group.default.id]
    }
  }) : null
  auto_ha_availability_zonef = length(data.aws_subnet.defaultf) > 0 ? ({
    "${data.aws_region.current.name}f" : {
      "subnet_id" : data.aws_subnet.defaultf[0].id,
      "security_groups" : [data.aws_security_group.default.id]
    }
  }) : null
  ha_zone_mapping = merge(local.auto_ha_availability_zonea, local.auto_ha_availability_zoneb, local.auto_ha_availability_zonec, local.auto_ha_availability_zoned, local.auto_ha_availability_zonee, local.auto_ha_availability_zonef)
  user_zone_mapping = var.zone_mapping != null ? ({
    for k, val in var.zone_mapping : "${data.aws_region.current.name}${k}" => val
  }) : local.no_zone_mapping

  mount_target      = var.zone_mapping != null ? local.user_zone_mapping : (var.create_ha_efs == true ? local.ha_zone_mapping : (length(aws_instance.server) > 0 ? local.ec2_zone_mapping : local.no_zone_mapping))
  mount_efs         = var.mount_efs && var.mount_efs_security_group_id != null ? 1 : (var.create_efs ? 1 : 0)
  mount_efs_warning = var.mount_efs_security_group_id == null ? "To mount EFS specify the EFS ID as well as the primary security group id used by the EFS." : ""

  replica_destination = var.replication_configuration_destination ? var.replication_configuration_destination : data.aws_region.current.name
}

# ---------------------CREATE--------------------------- #
resource "aws_efs_file_system" "efs" {
  # File system
  count          = var.create_efs ? 1 : 0
  creation_token = "${var.aws_resource_identifier}-token-modular"
  encrypted      = true

  lifecycle_policy {
    transition_to_ia = var.transition_to_inactive
  }

  tags = {
    Name = "${var.aws_resource_identifier}-efs-modular"
  }
}

resource "aws_efs_mount_target" "efs_mount_targets" {
  count           = var.create_efs ? 1 : 0
  for_each        = local.mount_target
  file_system_id  = aws_efs_file_system.efs.id
  subnet_id       = each.value["subnet_id"]
  security_groups = each.value["security_groups"]
}

resource "aws_security_group" "efs_security_group" {
  count  = var.create_efs ? 1 : 0
  name   = "${var.aws_resource_identifier}-security-group"
  vpc_id = data.aws_vpc.default.id

  ingress {
    description      = "TLS from VPC"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "HTTP from VPC"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.aws_resource_identifier}-security-group"
  }
}

resource "aws_efs_backup_policy" "efs_policy" {
  count          = var.enable_efs_backup_policy && var.create_efs ? 1 : 0
  file_system_id = aws_efs_file_system.efs.id

  backup_policy {
    status = "ENABLED"
  }
}

resource "aws_efs_replication_configuration" "efs_rep_config" {
  count                 = var.create_efs_replica && var.create_efs ? 1 : 0
  source_file_system_id = aws_efs_file_system.efs.id

  destination {
    region = local.replica_destination
  }
}

# resource "aws_efs_file_system_policy" "policy" {
#   file_system_id = aws_efs_file_system.efs.id

#   bypass_policy_lockout_safety_check = false

#   policy = <<POLICY
# POLICY
# }

# resource "aws_efs_access_point" "efs" {
#   file_system_id = aws_efs_file_system.efs.id
# }

# Whitelist the EFS security group for the EC2 Security Group
resource "aws_security_group_rule" "ingress_ec2_to_efs" {
  count                    = var.create_efs ? 1 : 0
  type                     = "ingress"
  description              = "${var.aws_resource_identifier} - EFS"
  from_port                = 443
  to_port                  = 443
  protocol                 = "all"
  source_security_group_id = aws_security_group.efs_security_group.id
  security_group_id        = data.aws_security_group.ec2_security_group.id
}

resource "aws_security_group_rule" "ingress_efs_to_ec2" {
  count                    = var.create_efs ? 1 : 0
  type                     = "ingress"
  description              = "${var.aws_resource_identifier} - NFS EFS"
  from_port                = 443
  to_port                  = 443
  protocol                 = "all"
  source_security_group_id = data.aws_security_group.ec2_security_group.id
  security_group_id        = aws_security_group.efs_security_group.id
}
# ----------------------------------------------------- #

# ---------------------MOUNT--------------------------- #
data "aws_efs_file_system" "mount_efs" {
  count          = var.mount_efs_id != null ? 1 : 0
  file_system_id = var.mount_efs_id
}

resource "aws_security_group_rule" "mount_ingress_ec2_to_efs" {
  count                    = var.mount_efs_security_group_id != null ? 1 : 0
  type                     = "ingress"
  description              = "${var.aws_resource_identifier} - EFS"
  from_port                = 443
  to_port                  = 443
  protocol                 = "all"
  source_security_group_id = var.mount_efs_security_group_id
  security_group_id        = data.aws_security_group.ec2_security_group.id
}

resource "aws_security_group_rule" "mount_ingress_efs_to_ec2" {
  count                    = var.mount_efs_security_group_id != null ? 1 : 0
  type                     = "ingress"
  description              = "${var.aws_resource_identifier} - NFS EFS"
  from_port                = 443
  to_port                  = 443
  protocol                 = "all"
  source_security_group_id = data.aws_security_group.ec2_security_group.id
  security_group_id        = var.mount_efs_security_group_id
}


# -------------------------------------------------------- #
locals {
  efs_url = length(aws_efs_file_system.efs) > 0 ? aws_efs_file_system.efs.dns_name : ""
}

output "efs_url" {
  value = local.efs_url
}

output "mount_target" {
  value = local.mount_target
}

output "mount_efs_info" {
  value = local.mount_efs_warning
}