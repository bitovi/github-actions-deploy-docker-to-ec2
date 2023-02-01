resource "aws_security_group" "pg_security_group" {
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
  type              = "ingress"
  description       = "${var.aws_resource_identifier} - pgPort"
  # TODO: parameterize the ports
  from_port         = 5432
  to_port           = 5432
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.pg_security_group.id
}

data "aws_vpc" "default" {
  default = true
} 
data "aws_subnets" "vpc_subnets" {
  filter {
    name   = "vpc-id"
    values = [var.vpc_id ? var.vpc_id : data.aws_vpc.default.id]
  }
}

module "rds_cluster" {
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
  subnets                = var.postgres_subnets == null ? data.aws_subnets.vpc_subnets.data.ids : var.postgres_subnets

  database_name          = var.postgres_database_name
  storage_encrypted      = true
  monitoring_interval    = 60
  create_db_subnet_group = true
  db_subnet_group_name   = var.aws_resource_identifier
  create_security_group  = false
  vpc_security_group_ids = [aws_security_group.pg_security_group.id]

  # TODO: take advantage of iam database auth
  iam_database_authentication_enabled    = true
  master_password                        = random_password.master.result
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

resource "random_password" "master" {
  length = 10
}

####
# aws_db_subnet_group
output "db_subnet_group_name" {
  description = "The db subnet group name"
  value       = module.rds_cluster.db_subnet_group_name
}

# aws_rds_cluster
output "cluster_arn" {
  description = "Amazon Resource Name (ARN) of cluster"
  value       = module.rds_cluster.cluster_arn
}

output "cluster_id" {
  description = "The RDS Cluster Identifier"
  value       = module.rds_cluster.cluster_id
}

output "cluster_resource_id" {
  description = "The RDS Cluster Resource ID"
  value       = module.rds_cluster.cluster_resource_id
}

output "cluster_members" {
  description = "List of RDS Instances that are a part of this cluster"
  value       = module.rds_cluster.cluster_members
}

output "cluster_endpoint" {
  description = "Writer endpoint for the cluster"
  value       = module.rds_cluster.cluster_endpoint
}

output "cluster_reader_endpoint" {
  description = "A read-only endpoint for the cluster, automatically load-balanced across replicas"
  value       = module.rds_cluster.cluster_reader_endpoint
}

output "cluster_engine_version_actual" {
  description = "The running version of the cluster database"
  value       = module.rds_cluster.cluster_engine_version_actual
}

# database_name is not set on `aws_rds_cluster` resource if it was not specified, so can't be used in output
output "cluster_database_name" {
  description = "Name for an automatically created database on cluster creation"
  value       = module.rds_cluster.cluster_database_name
}

output "cluster_port" {
  description = "The database port"
  value       = module.rds_cluster.cluster_port
}

output "cluster_master_password" {
  description = "The database master password"
  value       = module.rds_cluster.cluster_master_password
  sensitive   = true
}

output "cluster_master_username" {
  description = "The database master username"
  value       = module.rds_cluster.cluster_master_username
  sensitive   = true
}

output "cluster_hosted_zone_id" {
  description = "The Route53 Hosted Zone ID of the endpoint"
  value       = module.rds_cluster.cluster_hosted_zone_id
}

# aws_rds_cluster_instances
output "cluster_instances" {
  description = "A map of cluster instances and their attributes"
  value       = module.rds_cluster.cluster_instances
}

# aws_rds_cluster_endpoint
output "additional_cluster_endpoints" {
  description = "A map of additional cluster endpoints and their attributes"
  value       = module.rds_cluster.additional_cluster_endpoints
}

# aws_rds_cluster_role_association
output "cluster_role_associations" {
  description = "A map of IAM roles associated with the cluster and their attributes"
  value       = module.rds_cluster.cluster_role_associations
}

# Enhanced monitoring role
output "enhanced_monitoring_iam_role_name" {
  description = "The name of the enhanced monitoring role"
  value       = module.rds_cluster.enhanced_monitoring_iam_role_name
}

output "enhanced_monitoring_iam_role_arn" {
  description = "The Amazon Resource Name (ARN) specifying the enhanced monitoring role"
  value       = module.rds_cluster.enhanced_monitoring_iam_role_arn
}

output "enhanced_monitoring_iam_role_unique_id" {
  description = "Stable and unique string identifying the enhanced monitoring role"
  value       = module.rds_cluster.enhanced_monitoring_iam_role_unique_id
}

# aws_security_group
output "security_group_id" {
  description = "The security group ID of the cluster"
  value       = module.rds_cluster.security_group_id
}

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
