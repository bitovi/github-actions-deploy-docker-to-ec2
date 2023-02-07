resource "aws_security_group" "pg_security_group" {
  count = var.enable_postgres == "true" ? 1 : 0
  name        = var.security_group_name_pg
  description = "SG for ${var.aws_resource_identifier} - PG"
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${var.aws_resource_identifier}-pg"
  }
}


resource "aws_security_group_rule" "ingress_postgres" {
  count = var.enable_postgres == "true" ? 1 : 0
  type              = "ingress"
  description       = "${var.aws_resource_identifier} - pgPort"
  # TODO: parameterize the ports
  from_port         = 5432
  to_port           = 5432
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.pg_security_group[0].id
}

module "rds_cluster" {
  count = var.enable_postgres == "true" ? 1 : 0
  depends_on     = [data.aws_subnets.vpc_subnets]
  source         = "terraform-aws-modules/rds-aurora/aws"
  version        = "v7.6.0"
  name           = var.aws_resource_identifier
  engine         = var.postgres_engine
  engine_version = var.postgres_engine_version
  instance_class = var.postgres_instance_class
  instances = {
    1 = {
      instance_class = var.postgres_instance_class
    }
  }

    # Todo: handle vpc/networking explicitly
  # vpc_id                 = var.vpc_id
  # allowed_cidr_blocks    = [var.vpc_cidr]
  subnets                  = var.postgres_subnets == null || length(var.postgres_subnets) == 0 ? data.aws_subnets.vpc_subnets.ids : var.postgres_subnets

  database_name          = var.postgres_database_name
  storage_encrypted      = true
  monitoring_interval    = 60
  create_db_subnet_group = true
  db_subnet_group_name   = var.aws_resource_identifier
  create_security_group  = false
  vpc_security_group_ids = [aws_security_group.pg_security_group[0].id]

  # TODO: take advantage of iam database auth
  iam_database_authentication_enabled    = true
  master_password                        = random_password.rds.result
  create_random_password                 = false
  apply_immediately                      = true
  skip_final_snapshot                    = true
  create_db_cluster_parameter_group      = true
  db_cluster_parameter_group_name        = var.aws_resource_identifier
  db_cluster_parameter_group_family      = "aurora-postgresql11"
  db_cluster_parameter_group_description = "${var.aws_resource_identifier}  cluster parameter group"
  db_cluster_parameter_group_parameters = [
    {
      name         = "log_min_duration_statement"
      value        = 4000
      apply_method = "immediate"
      }, {
      name         = "rds.force_ssl"
      value        = 1
      apply_method = "immediate"
    }
  ]
  create_db_parameter_group      = true
  db_parameter_group_name        = var.aws_resource_identifier
  db_parameter_group_family      = "aurora-postgresql11"
  db_parameter_group_description = "${var.aws_resource_identifier} example DB parameter group"
  db_parameter_group_parameters = [
    {
      name         = "log_min_duration_statement"
      value        = 4000
      apply_method = "immediate"
    }
  ]
  enabled_cloudwatch_logs_exports = ["postgresql"]
  tags = {
    Name = "${var.aws_resource_identifier}-RDS"
  }
}

resource "random_password" "rds" {
  length = 10
}

#####
#output "aws_rds_postgres_subnets_input" {
#  description = "The subnet ids input from the user"
#  value       = var.postgres_subnets
#}
#
#output "aws_rds_postgres_default_subnet_ids_conditional" {
#  description = "What subnets actually get passed to the rds cluster"
#  value       = var.postgres_subnets == null || length(var.postgres_subnets) == 0 ? data.aws_subnets.vpc_subnets.ids : var.postgres_subnets
#}
#
## aws_db_subnet_group
#output "aws_rds_postgres_subnet_group_name" {
#  description = "The db subnet group name"
#  value       = module.rds_cluster[0].db_subnet_group_name
#}
#
## aws_rds_cluster
#output "aws_rds_postgres_cluster_arn" {
#  description = "Amazon Resource Name (ARN) of cluster"
#  value       = module.rds_cluster[0].cluster_arn
#}
#
#output "aws_rds_postgres_cluster_id" {
#  description = "The RDS Cluster Identifier"
#  value       = module.rds_cluster[0].cluster_id
#}
#
#output "aws_rds_postgres_cluster_resource_id" {
#  description = "The RDS Cluster Resource ID"
#  value       = module.rds_cluster[0].cluster_resource_id
#}
#
#output "aws_rds_postgres_cluster_members" {
#  description = "List of RDS Instances that are a part of this cluster"
#  value       = module.rds_cluster[0].cluster_members
#}
#
#output "aws_rds_postgres_cluster_endpoint" {
#  description = "Writer endpoint for the cluster"
#  value       = module.rds_cluster[0].cluster_endpoint
#}
#
#output "aws_rds_postgres_cluster_reader_endpoint" {
#  description = "A read-only endpoint for the cluster, automatically load-balanced across replicas"
#  value       = module.rds_cluster[0].cluster_reader_endpoint
#}
#
#output "aws_rds_postgres_cluster_engine_version_actual" {
#  description = "The running version of the cluster database"
#  value       = module.rds_cluster[0].cluster_engine_version_actual
#}
#
## database_name is not set on `aws_rds_cluster` resource if it was not specified, so can't be used in output
#output "aws_rds_postgres_cluster_database_name" {
#  description = "Name for an automatically created database on cluster creation"
#  value       = module.rds_cluster[0].cluster_database_name
#}
#
#output "aws_rds_postgres_cluster_port" {
#  description = "The database port"
#  value       = module.rds_cluster[0].cluster_port
#}
#
#output "aws_rds_postgres_cluster_master_password" {
#  description = "The database master password"
#  value       = module.rds_cluster[0].cluster_master_password
#  sensitive   = true
#}
#
#output "aws_rds_postgres_cluster_master_username" {
#  description = "The database master username"
#  value       = module.rds_cluster[0].cluster_master_username
#  sensitive   = true
#}
#
#output "aws_rds_postgres_cluster_hosted_zone_id" {
#  description = "The Route53 Hosted Zone ID of the endpoint"
#  value       = module.rds_cluster[0].cluster_hosted_zone_id
#}
#
## aws_rds_cluster_instances
#output "aws_rds_postgres_cluster_instances" {
#  description = "A map of cluster instances and their attributes"
#  value       = module.rds_cluster[0].cluster_instances
#}
#
## aws_rds_cluster_endpoint
#output "aws_rds_postgres_additional_cluster_endpoints" {
#  description = "A map of additional cluster endpoints and their attributes"
#  value       = module.rds_cluster[0].additional_cluster_endpoints
#}
#
## aws_rds_cluster_role_association
#output "aws_rds_postgres_cluster_role_associations" {
#  description = "A map of IAM roles associated with the cluster and their attributes"
#  value       = module.rds_cluster[0].cluster_role_associations
#}
#
## Enhanced monitoring role
#output "aws_rds_postgres_enhanced_monitoring_iam_role_name" {
#  description = "The name of the enhanced monitoring role"
#  value       = module.rds_cluster[0].enhanced_monitoring_iam_role_name
#}
#
#output "aws_rds_postgres_enhanced_monitoring_iam_role_arn" {
#  description = "The Amazon Resource Name (ARN) specifying the enhanced monitoring role"
#  value       = module.rds_cluster[0].enhanced_monitoring_iam_role_arn
#}
#
#output "aws_rds_postgres_enhanced_monitoring_iam_role_unique_id" {
#  description = "Stable and unique string identifying the enhanced monitoring role"
#  value       = module.rds_cluster[0].enhanced_monitoring_iam_role_unique_id
#}
#
## aws_security_group
#output "aws_rds_postgres_security_group_id" {
#  description = "The security group ID of the cluster"
#  value       = module.rds_cluster[0].security_group_id
#}

# do we need db to be created and priviliges to be granted ? 

# provider "cyrilgdn-postgresql" {
#   host            = module.rds_cluster.cluster_endpoint
#   port            = 5432
#   database        = "postgres"
#   username        = module.rds_cluster.cluster_master_username
#   password        = module.rds_cluster.cluster_master_password
#   sslmode         = "require"
#   connect_timeout = 15
#   expected_version = module.rds_cluster.engine_version
#   superuser        = var.superuser
#   alias            = "yc-postgresql-root"
# }

# resource "time_sleep" "wait_seconds" {
#   create_duration = 180 #var.create_duration_wait_seconds
#   depends_on      = [module.rds_cluster]
# }

# resource "postgresql_database" "my_db" {
# providers = {
#     postgresql = cyrilgdn-postgresql.yc-postgresql-root
#   }  
#   name              = "my_db"
#   owner             = "my_role"
#   template          = "template0"
#   lc_collate        = "C"
#   connection_limit  = -1
#   allow_connections = true
# }
