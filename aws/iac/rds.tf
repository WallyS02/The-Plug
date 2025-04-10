module "rds" {
  source = "./modules/rds"

  identifier              = "the-plug-db"
  engine                  = "postgres"
  engine_version          = "17.4"
  instance_class          = "db.t3.micro"
  allocated_storage       = 20
  storage_type            = "gp3"
  db_name                 = "postgres"
  username                = "admin"
  password                = module.secrets_rds.initial_value
  port                    = 5432
  subnet_ids              = module.vpc.private_subnet_ids
  backup_retention_period = 1
  backup_window           = "02:00-03:00"
  maintenance_window      = "Sun:02:00-Sun:03:00"

  parameters = [
    {
      name         = "shared_buffers"
      value        = "256MB"
      apply_method = "immediate"
    },
    {
      name         = "max_connections"
      value        = "100"
      apply_method = "immediate"
    },
    {
      name         = "work_mem"
      value        = "8MB"
      apply_method = "immediate"
    }
  ]

  parameters_group_family      = "postgres17"
  rds_security_group           = [module.rds_security_group.id]
  deletion_protection          = false
  performance_insights_enabled = false
  skip_final_snapshot          = true
  alarm_topic_arn              = module.alarm_topic.arn

  tags = {
    Environment = "dev"
  }
}

module "rds_security_group" {
  source = "./modules/security-groups"

  name        = "rds-security-group"
  description = "Security group for RDS database in private subnet"
  vpc_id      = module.vpc.vpc_id
  ingress_rules = [
    {
      from_port       = 5432
      to_port         = 5432
      description     = "Allowing communication on port 5432"
      protocol        = "tcp"
      security_groups = [module.elasticache.security_group_id, module.asg.security_group_id]
    }
  ]

  tags = {
    Environment = "dev"
  }
}

resource "random_password" "rds_password" {
  length           = 16
  min_upper        = 1
  min_lower        = 1
  min_numeric      = 1
  override_special = "!@#%^&*"
}

module "secrets_rds" {
  source = "./modules/secrets-manager"

  name             = "rds-password"
  description      = "Password for RDS database"
  initial_value    = random_password.rds_password.result
  rotation_enabled = false
  policy_statements = [
    data.aws_iam_policy_document.rds_access.json
  ]

  tags = {
    Environment = "dev"
  }
}

data "aws_iam_policy_document" "rds_access" {
  statement {
    effect    = "Allow"
    actions   = ["secretsmanager:GetSecretValue"]
    resources = [module.secrets_rds.arn]
    principals {
      type        = "Service"
      identifiers = ["rds.amazonaws.com", "ecs.amazonaws.com"]
    }
  }
}