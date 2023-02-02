variable "app_port" {
  type        = string
  default     = "3000"
  description = "app port"
}
variable "lb_port" {
  type        = string
  default     = ""
  description = "Load balancer listening port. Defaults to 80 if NO FQDN provided, 443 if FQDN provided"
}
variable "lb_healthcheck" {
  type        = string
  default     = ""
  description = "Load balancer health check string. Defaults to HTTP:app_port"
}
variable "app_repo_name" {
  type        = string
  description = "GitHub Repo Name"
}
variable "app_org_name" {
  type        = string
  description = "GitHub Org Name"
}
variable "app_branch_name" {
  type        = string
  description = "GitHub Branch Name"
}

variable "app_install_root" {
  type        = string
  description = "Path on the instance where the app will be cloned (do not include app_repo_name)."
  default     = "/home/ubuntu"
}

variable "os_system_user" {
  type        = string
  description = "User for the OS"
  default     = "ubuntu"
}

variable "ops_repo_environment" {
  type        = string
  description = "Ops Repo Environment (i.e. directory name)"
}

variable "ec2_instance_type" {
  type        = string
  default     = "t2.small"
  description = "Instance type for the EC2 instance"
}
variable "ec2_instance_public_ip" {
  type        = string
  default     = "true"
  description = "Attach public IP to the EC2 instance"
}
variable "security_group_name" {
  type        = string
  default     = "SG for deployment"
  description = "Name of the security group to use"
}
variable "ec2_iam_instance_profile" {
  type        = string
  description = "IAM role for the ec2 instance"
  default     = ""
}
variable "lb_access_bucket_name" {
  type        = string
  description = "s3 bucket for the lb access logs"
}

variable "aws_resource_identifier" {
  type        = string
  description = "Identifier to use for AWS resources (defaults to GITHUB_ORG-GITHUB_REPO-GITHUB_BRANCH)"
}

variable "aws_resource_identifier_supershort" {
  type        = string
  description = "Identifier to use for AWS resources (defaults to GITHUB_ORG-GITHUB_REPO-GITHUB_BRANCH) shortened to 30 chars"
}

variable "aws_secret_env" {
  type        = string
  description = "Secret name to pull env variables from AWS Secret Manager"
}

variable "aws_ami_id" {
  type        = string
  description = "AWS AMI ID image to use for deployment"
  default     = ""
}

variable "sub_domain_name" {
  type        = string
  description = "Subdomain name for DNS record"
  default     = ""
}
variable "domain_name" {
  type        = string
  description = "root domain name without any subdomains"
  default     = ""
}
variable "root_domain" {
  type        = string
  description = "deploy to root domain"
  default     = ""
}

variable "cert_arn" {
  type        = string
  description = "Certificate ARN to use"
  default     = ""
}

variable "create_root_cert" {
  type        = string
  description = "deploy to root domain"
  default     = ""
}

variable "create_sub_cert" {
  type        = string
  description = "deploy to root domain"
  default     = ""
}

variable "no_cert" {
  type        = bool
  description = "disable cert lookup"
  default     = false
}


## -- EFS -- ##
variable "create_efs" {
  type        = bool
  description = "Toggle to indicate whether to create and EFS and mount it to the ec2 as a part of the provisioning. Note: The EFS will be managed by the stack and will be destroyed along with the stack."
  default     = false
}

variable "create_ha_efs" {
  type        = bool
  description = "Toggle to indicate whether the EFS resource should be highly available (target mounts in all available zones within region)."
  default     = false
}

variable "create_efs_replica" {
  type        = bool
  description = "Toggle to indiciate whether a read-only replica should be created for the EFS primary file system"
  default     = false
}

variable "enable_efs_backup_policy" {
  type        = bool
  default     = false
  description = "Toggle to indiciate whether the EFS should have a backup policy, default is `false`"
}

variable "mount_efs" {
  type        = bool
  description = "Toggle to indicate whether to mount an existing EFS to the ec2 deployment"
  default     = false
}

variable "mount_efs_id" {
  type        = string
  description = "ID of existing EFS"
}

variable "mount_efs_security_group_id" {
  type        = string
  description = "ID of the primary security group used by the existing EFS"
  default     = null
}

variable "zone_mapping" {
  type = map(object({
    subnet_id       = string
    security_groups = list(string)
  }))
  description = "Zone Mapping in the form of {\"<availabillity zone>\":{\"subnet_id\":\"subnet-abc123\", \"security_groups\":[\"sg-abc123\"]} }"
  nullable    = true
  default     = null
}

variable "transition_to_inactive" {
  type        = string
  default     = "AFTER_30_DAYS"
  description = "https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/efs_file_system#transition_to_ia"
}

variable "replication_configuration_destination" {
  type        = string
  default     = null
  description = "AWS Region to target for replication"
}

## -- --- -- ##

variable "additional_tags" {
  type        = map(string)
  description = "A list of strings that will be added to created resources"
  default     = {}
}
