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
