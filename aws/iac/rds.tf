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
      name         = "character_set_server"
      value        = "utf8mb4"
      apply_method = "immediate"
    }
  ]

  parameters_group_family      = "postgres17"
  rds_security_group           = [module.rds_security_group.id]
  deletion_protection          = true
  performance_insights_enabled = false
  skip_final_snapshot          = true
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
      security_groups = [module.elasticache.security_group_id]
    }
  ]
}

resource "random_password" "rds_password" {
  length  = 16
  special = true
}

module "secrets_rds" {
  source = "./modules/secrets-manager"

  name             = "rds-password"
  description      = "Password for RDS database"
  initial_value    = random_password.rds_password.result
  rotation_enabled = false
  recovery_window  = 7
  policy_statements = [
    data.aws_iam_policy_document.rds_access.json
  ]
}

data "aws_iam_policy_document" "rds_access" {
  statement {
    effect    = "Allow"
    actions   = ["secretsmanager:GetSecretValue"]
    resources = [module.secrets_rds.arn]
    principals {
      type        = "Service"
      identifiers = ["rds.amazonaws.com"]
    }
  }
}