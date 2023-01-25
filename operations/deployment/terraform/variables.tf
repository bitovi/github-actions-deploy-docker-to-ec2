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
  type        = string
  description = "disable cert lookup"
  default     = ""
}

variable "enable_postgres" {
  type        = string
  description = "deploy a postgres database"
  default     = ""
}
variable "postgres_engine" {
  type        = string
  description = "The engine to use for postgres.  Defaults to `aurora-postgresql`.  For more details, see: https://aws.amazon.com/rds/, https://registry.terraform.io/modules/terraform-aws-modules/rds-aurora/aws/latest?tab=inputs"
  default     = "aurora-postgresql"
}
variable "postgres_engine_version" {
  type        = string
  description = "The version of the engine to use for postgres.  Defaults to `11.13`."
  default     = "11.13"
}
variable "postgres_instance_class" {
  type        = string
  description = "The size of the db instances.  For more details, see: https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Concepts.DBInstanceClass.html, https://registry.terraform.io/modules/terraform-aws-modules/rds-aurora/aws/latest?tab=inputs"
  default     = "db.t3.medium"
}
variable "postgres_subnets" {
  type        = list
  description = "The list of subnet ids to use for postgres. For more details, see: https://registry.terraform.io/modules/terraform-aws-modules/rds-aurora/aws/latest?tab=inputs"
  default     = []
}

variable "additional_tags" {
  type        = map(string)
  description = "A list of strings that will be added to created resources"
  default     = {}
}
