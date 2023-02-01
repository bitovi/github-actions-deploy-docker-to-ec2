locals {
  no_zone_mapping = { "": {"subnet_id": "", "security_groups": [""]}}
  ec2_zone_mapping = {"${data.aws_instance.server.availability_zone}": { "subnet_id": "${data.aws_instance.server.subnet_id}", "security_groups": [aws_security_group.ec2_security_group.id] }}
  
  auto_ha_availability_zonea = {
    "${data.aws_region.current.name}a": {
      "subnet_id": data.aws_subnet.defaulta.id, 
      "security_groups": [data.aws_security_group.default.id]
  }}
  auto_ha_availability_zoneb = length(data.aws_subnet.defaultb) > 0 ? ({
    "${data.aws_region.current.name}b": {
      "subnet_id": data.aws_subnet.defaultb[0].id, 
      "security_groups": [data.aws_security_group.default.id]
    }
  }) : null
  auto_ha_availability_zonec = length(data.aws_subnet.defaultc) > 0 ? ({
    "${data.aws_region.current.name}c": {
      "subnet_id": data.aws_subnet.defaultc[0].id, 
      "security_groups": [data.aws_security_group.default.id]
    }
  }) : null
  auto_ha_availability_zoned = length(data.aws_subnet.defaultd) > 0 ? ({
    "${data.aws_region.current.name}d": {
      "subnet_id": data.aws_subnet.defaultd[0].id, 
      "security_groups": [data.aws_security_group.default.id]
    }
  }) : null
  auto_ha_availability_zonee = length(data.aws_subnet.defaulte) > 0 ? ({
    "${data.aws_region.current.name}e": {
      "subnet_id": data.aws_subnet.defaulte[0].id, 
      "security_groups": [data.aws_security_group.default.id]
    }
  }) : null
  auto_ha_availability_zonef = length(data.aws_subnet.defaultf) > 0 ? ({
    "${data.aws_region.current.name}f": {
      "subnet_id": data.aws_subnet.defaultf[0].id, 
      "security_groups": [data.aws_security_group.default.id]
    }
  }) : null
  ha_zone_mapping = merge(local.auto_ha_availability_zonea, local.auto_ha_availability_zoneb, local.auto_ha_availability_zonec, local.auto_ha_availability_zoned, local.auto_ha_availability_zonee, local.auto_ha_availability_zonef)
  mount_efs = var.mount_efs ? 1 : (var.create_efs ? 1 : 0)
}

module "efs" {
    count = var.create_efs ? 1 : 0
    source = "terraform-aws-modules/efs/aws"

    # File system
    name           = "${var.aws_resource_identifier}-efs"
    creation_token = "${var.aws_resource_identifier}-token"

    lifecycle_policy = {
        transition_to_ia = var.transition_to_inactive
        transition_to_primary_storage_class = var.transition_to_primary_storage_class
    }

    # File system policy
    attach_policy                      = false
    bypass_policy_lockout_safety_check = false

    # Mount targets / security group
    mount_targets = var.create_ha_efs == true ? local.ha_zone_mapping : ( length(aws_instance.server) > 0 ? local.ec2_zone_mapping : local.no_zone_mapping)

    # Backup policy
    enable_backup_policy = var.enable_backup_policy

    # Replication configuration
    create_replication_configuration = var.create_replication_configuration
    replication_configuration_destination = var.replication_configuration_destination
    depends_on = [aws_security_group.ec2_security_group]
}

locals {
  efs_url = length(module.efs) > 0 ? module.efs[0].dns_name : ""
}


# Whitelist the EFS security group for the EC2 Security Group
resource "aws_security_group_rule" "ingress_efs" {
  count = var.create_efs ? 1 : 0
  type        = "ingress"
  description = "${var.aws_resource_identifier} - EFS"
  from_port   = 443
  to_port     = 443
  protocol    = "all"
  source_security_group_id = module.efs[0].security_group_id
  security_group_id = aws_security_group.ec2_security_group.id
}

data "aws_security_group" "efs" {
  count = var.create_efs ? 1 : 0
  id = module.efs[0].security_group_id
}

# Whitelist the EFS security group for the EC2 Security Group
resource "aws_security_group_rule" "ingress_nfs_efs" {
  count = var.create_efs ? 1 : 0
  type        = "ingress"
  description = "${var.aws_resource_identifier} - NFS EFS"
  from_port   = 443
  to_port     = 443
  protocol    = "all"
  source_security_group_id = aws_security_group.ec2_security_group.id
  security_group_id = data.aws_security_group.efs[0].id
}

output "efs_url" {
  value = local.efs_url
}

output "ec2_zone_mapping" {
  value = local.ec2_zone_mapping
}

output "no_zone_mapping" {
  value = local.no_zone_mapping
}

output "auto_ha_zone_mapping" {
  value = local.ha_zone_mapping
}
