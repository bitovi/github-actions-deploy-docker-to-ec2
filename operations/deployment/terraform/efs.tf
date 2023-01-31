locals {
  default_zone_mapping = { "": {"subnet_id": "", "security_groups": [""]}}
  default_availability_zones = {
    "a": {
      "subnet_id": data.aws_subnet.defaulta.id, 
      "security_groups": [data.aws_security_group.default.id]
    }
    "b": {
      "subnet_id": data.aws_subnet.defaultb.id, 
      "security_groups": [data.aws_security_group.default.id]
    }
    "c": {
      "subnet_id": data.aws_subnet.defaultc.id, 
      "security_groups": [data.aws_security_group.default.id]
    }
    "d": {
      "subnet_id": data.aws_subnet.defaultd.id, 
      "security_groups": [data.aws_security_group.default.id]
    }
    "e": {
      "subnet_id": data.aws_subnet.defaulte.id, 
      "security_groups": [data.aws_security_group.default.id]
    }
    "f": {
      "subnet_id": data.aws_subnet.defaultf.id, 
      "security_groups": [data.aws_security_group.default.id]
    }
  }
  
  // The reason the conditional is needed is because zone_mapping can't be null for the local creation.
  zone_mapping = var.zone_mapping == null ? local.default_zone_mapping : var.zone_mapping
  availability_zones = {
    for k, val in local.zone_mapping : "${data.aws_region.current.name}${k}" => val
  }

  mount_efs = var.mount_efs ? 1 : (var.create_efs ? 1 : 0)
}

module "efs" {
    lifecycle {
      prevent_destroy = var.efs_prevent_destroy
    }
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
    mount_targets = var.zone_mapping == null ? local.default_availability_zones : local.availability_zones

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
