resource "aws_security_group" "pg_security_group" {
  count = var.aws_enable_postgres == "true" ? 1 : 0
  name        = var.aws_security_group_name_pg
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
  count = var.aws_enable_postgres == "true" ? 1 : 0
  type              = "ingress"
  description       = "${var.aws_resource_identifier} - pgPort"
  from_port         = tonumber(var.aws_postgres_database_port)
  to_port           = tonumber(var.aws_postgres_database_port)
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.pg_security_group[0].id
}

module "rds_cluster" {
  count = var.aws_enable_postgres == "true" ? 1 : 0
  depends_on     = [data.aws_subnets.vpc_subnets]
  source         = "terraform-aws-modules/rds-aurora/aws"
  version        = "v7.7.1"
  name           = var.aws_resource_identifier
  engine         = var.aws_postgres_engine
  engine_version = var.aws_postgres_engine_version
  instance_class = var.aws_postgres_instance_class
  instances = {
    1 = {
      instance_class = var.aws_postgres_instance_class
    }
  }

    # Todo: handle vpc/networking explicitly
  # vpc_id                 = var.vpc_id
  # allowed_cidr_blocks    = [var.vpc_cidr]
  subnets                  = var.aws_postgres_subnets == null || length(var.aws_postgres_subnets) == 0 ? data.aws_subnets.vpc_subnets.ids : var.aws_postgres_subnets

  database_name          = var.aws_postgres_database_name
  port                   = var.aws_postgres_database_port
  deletion_protection    = var.aws_postgres_database_protection
  storage_encrypted      = true
  monitoring_interval    = 60
  create_db_subnet_group = true
  db_subnet_group_name   = "${var.aws_resource_identifier}-pg"
  create_security_group  = false
  vpc_security_group_ids = [aws_security_group.pg_security_group[0].id]

  # TODO: take advantage of iam database auth
  iam_database_authentication_enabled    = true
  master_password                        = random_password.rds.result
  create_random_password                 = false
  apply_immediately                      = true
  skip_final_snapshot                    = var.aws_postgres_database_final_snapshot == "" ? true : false
  snapshot_identifier                    = var.aws_postgres_database_final_snapshot
  create_db_cluster_parameter_group      = true
  db_cluster_parameter_group_name        = var.aws_resource_identifier
  db_cluster_parameter_group_family      = var.aws_postgres_database_group_family
  db_cluster_parameter_group_description = "${var.aws_resource_identifier}  cluster parameter group"
  db_cluster_parameter_group_parameters = var.aws_postgres_engine == "aurora-postgresql" ? [
    {
      name         = "log_min_duration_statement"
      value        = 4000
      apply_method = "immediate"
      }, {
      name         = "rds.force_ssl"
      value        = 1
      apply_method = "immediate"
    }
  ] : [
    {
      name         = "require_secure_transport"
      value        = "ON"
      apply_method = "immediate"
    }
  ]

  create_db_parameter_group      = true
  db_parameter_group_name        = var.aws_resource_identifier
  db_parameter_group_family      = var.aws_postgres_database_group_family
  db_parameter_group_description = "${var.aws_resource_identifier} example DB parameter group"
  db_parameter_group_parameters = var.aws_postgres_engine == "aurora-postgresql" ? [
    {
      name         = "log_min_duration_statement"
      value        = 4000
      apply_method = "immediate"
    }
  ] : []
  enabled_cloudwatch_logs_exports = var.aws_postgres_engine == "aurora-postgresql" ? ["postgresql"] : ["audit","error","general","slowquery"]
  tags = {
    Name = "${var.aws_resource_identifier}-RDS"
  }
}

resource "random_password" "rds" {
  length = 10
  special = false
}

// Creates a secret manager secret for the databse credentials
resource "aws_secretsmanager_secret" "database_credentials" {
   count = var.aws_enable_postgres == "true" ? 1 : 0
   name   = "${var.aws_resource_identifier_supershort}-ec2db-pub-${random_string.random_sm.result}"
}
 
resource "aws_secretsmanager_secret_version" "database_credentials_sm_secret_version" {
  count = var.aws_enable_postgres == "true" ? 1 : 0
  secret_id = aws_secretsmanager_secret.database_credentials[0].id
  secret_string = <<EOF
   {
    "key": "database_password",
    "value": "${sensitive(random_password.rds.result)}"
   }
EOF
}

resource "random_string" "random_sm" {
  length    = 5
  lower     = true
  special   = false
  numeric   = false
}