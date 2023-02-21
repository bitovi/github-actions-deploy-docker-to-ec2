locals {
  # no_zone_mapping: Creates a empty zone mapping object list
  no_zone_mapping  = { "" : { "subnet_id" : "", "security_groups" : [""] } }
  # ec2_zone_mapping: Creates a zone mapping object list based on default values (default sg, default subnet, etc)
  ec2_zone_mapping = { "${local.preferred_az}" : { "subnet_id" : "${data.aws_subnet.selected[0].id}", "security_groups" : [aws_security_group.ec2_security_group.name] } }

  # auto_ha_availability_zone*: Creates zone map objects for each available AZ in a region
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
  # ha_zone_mapping: Creates a zone mapping object list for all available AZs in a region
  ha_zone_mapping = merge(local.auto_ha_availability_zonea, local.auto_ha_availability_zoneb, local.auto_ha_availability_zonec, local.auto_ha_availability_zoned, local.auto_ha_availability_zonee, local.auto_ha_availability_zonef)
  # user_zone_mapping: Create a zone mapping object list for all user specified zone_maps
  user_zone_mapping = var.aws_efs_zone_mapping != null ? ({
    for k, val in var.aws_efs_zone_mapping : "${data.aws_region.current.name}${k}" => val
  }) : local.no_zone_mapping

  # mount_target: Fall-Through variable that checks multiple layers of EFS zone map selection
  mount_target      = var.aws_efs_zone_mapping != null ? local.user_zone_mapping : (var.aws_create_ha_efs == true ? local.ha_zone_mapping : (length(local.ec2_zone_mapping) > 0 ? local.ec2_zone_mapping : local.no_zone_mapping))
  # mount_efs: Fall-Through variable that checks multiple layers of EFS creation and if any of them are active, sets creation to active.
  mount_efs         = var.aws_mount_efs_id != null ? true : (local.create_efs ? true : false)

  # replica_destination: Checks whether a replica destination exists otherwise sets a default
  replica_destination  = var.aws_replication_configuration_destination != null ? var.aws_replication_configuration_destination : data.aws_region.current.name
  # create_mount_targets: boolean on whether to create mount_targets
  create_mount_targets = var.aws_create_efs || var.aws_create_ha_efs ? local.mount_target : {}
  # create_efs: boolean, checks whether to create an EFS or not
  create_efs           = var.aws_create_efs == true ? true : (var.aws_create_ha_efs == true ? true : false)
}

# ---------------------CREATE--------------------------- #
resource "aws_efs_file_system" "efs" {
  # File system
  count          = local.create_efs ? 1 : 0
  creation_token = "${var.aws_resource_identifier}-token-modular"
  encrypted      = true

  lifecycle_policy {
    transition_to_ia = var.aws_efs_transition_to_inactive
  }

  tags = {
    Name = "${var.aws_resource_identifier}-efs-modular"
  }
}

resource "aws_security_group" "efs_security_group" {
  count  = local.create_efs ? 1 : 0
  name   = "${var.aws_resource_identifier}-security-group"
  vpc_id = data.aws_vpc.default.id

  ingress {
    description = "TLS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.aws_resource_identifier}-security-group"
  }
}

resource "aws_efs_backup_policy" "efs_policy" {
  count          = var.aws_enable_efs_backup_policy && local.create_efs ? 1 : 0
  file_system_id = aws_efs_file_system.efs[0].id

  backup_policy {
    status = "ENABLED"
  }
}

resource "aws_efs_replication_configuration" "efs_rep_config" {
  count                 = var.aws_create_efs_replica && local.create_efs ? 1 : 0
  source_file_system_id = aws_efs_file_system.efs[0].id

  destination {
    region = local.replica_destination
  }
}

resource "aws_efs_mount_target" "efs_mount_targets" {
  for_each        = local.create_mount_targets
  file_system_id  = aws_efs_file_system.efs[0].id
  subnet_id       = each.value["subnet_id"]
  security_groups = [aws_security_group.efs_security_group[0].id]
}

# resource "aws_efs_file_system_policy" "policy" {
#   file_system_id = aws_efs_file_system.efs[0].id

#   bypass_policy_lockout_safety_check = false

#   policy = <<POLICY
# POLICY
# }

# resource "aws_efs_access_point" "efs" {
#   file_system_id = aws_efs_file_system.efs[0].id
# }

# Whitelist the EFS security group for the EC2 Security Group
resource "aws_security_group_rule" "ingress_ec2_to_efs" {
  count                    = local.create_efs ? 1 : 0
  type                     = "ingress"
  description              = "${var.aws_resource_identifier} - EFS"
  from_port                = 443
  to_port                  = 443
  protocol                 = "all"
  source_security_group_id = aws_security_group.efs_security_group[0].id
  security_group_id        = data.aws_security_group.ec2_security_group.id
}

resource "aws_security_group_rule" "ingress_efs_to_ec2" {
  count                    = local.create_efs ? 1 : 0
  type                     = "ingress"
  description              = "${var.aws_resource_identifier} - NFS EFS"
  from_port                = 443
  to_port                  = 443
  protocol                 = "all"
  source_security_group_id = data.aws_security_group.ec2_security_group.id
  security_group_id        = aws_security_group.efs_security_group[0].id
}
# ----------------------------------------------------- #

# ---------------------MOUNT--------------------------- #
data "aws_efs_file_system" "mount_efs" {
  count          = var.aws_mount_efs_id != null ? 1 : 0
  file_system_id = var.aws_mount_efs_id
}

resource "aws_security_group_rule" "mount_ingress_ec2_to_efs" {
  count                    = var.aws_mount_efs_security_group_id != null ? 1 : 0
  type                     = "ingress"
  description              = "${var.aws_resource_identifier} - EFS"
  from_port                = 443
  to_port                  = 443
  protocol                 = "all"
  source_security_group_id = var.aws_mount_efs_security_group_id
  security_group_id        = data.aws_security_group.ec2_security_group.id
}

resource "aws_security_group_rule" "mount_ingress_efs_to_ec2" {
  count                    = var.aws_mount_efs_security_group_id != null ? 1 : 0
  type                     = "ingress"
  description              = "${var.aws_resource_identifier} - NFS EFS"
  from_port                = 443
  to_port                  = 443
  protocol                 = "all"
  source_security_group_id = data.aws_security_group.ec2_security_group.id
  security_group_id        = var.aws_mount_efs_security_group_id
}


# -------------------------------------------------------- #
locals {
  create_efs_url = var.aws_create_efs ? aws_efs_file_system.efs[0].dns_name : ""
  mount_efs_url  = var.aws_mount_efs_id != null ? data.aws_efs_file_system.mount_efs[0].dns_name : ""
  efs_url        = local.create_efs_url != "" ? local.create_efs_url : local.mount_efs_url
}
