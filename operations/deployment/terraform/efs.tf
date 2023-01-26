locals {
  default_zone_mapping = { "": {"subnet_id": "", "security_groups": [""]}}

  zone_mapping = var.zone_mapping == null ? local.default_zone_mapping : var.zone_mapping

  availability_zones = {
    for k, val in local.zone_mapping : "${data.aws_region.current.name}${k}" => val
  }
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
    mount_targets = var.zone_mapping == null ? {} : local.availability_zones
    
    # Backup policy
    enable_backup_policy = var.enable_backup_policy

    # Replication configuration
    create_replication_configuration = var.create_replication_configuration
    replication_configuration_destination = var.replication_configuration_destination
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
  depends_on = [module.efs]
}

output "efs_url" {
  value = length(module.efs) > 0 ? module.efs[0].dns_name : null 
}
