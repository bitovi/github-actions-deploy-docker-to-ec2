module "rds_cluster" {
  source         = "terraform-aws-modules/rds-aurora/aws"
  name           = var.aws_resource_identifier
  engine         = "aurora-postgresql"
  engine_version = "11.12"
  instance_class = "db.t3.medium"
  instances = {
    1 = {
      instance_class = "db.t3.medium"
    }
  }
  vpc_id                 = "vpc-081abe910edab4281"
  subnets                = ["subnet-0f1b65df74adf6e87", "subnet-05d768eabcd7591ea", "subnet-082c8c6a0f81405d3"]
  allowed_cidr_blocks    = ["172.31.0.0/16"]
  storage_encrypted      = true
  monitoring_interval    = 60
  create_db_subnet_group = true
  db_subnet_group_name   = var.aws_resource_identifier
  create_security_group  = true
  security_group_egress_rules = {
    to_cidrs = {
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
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
