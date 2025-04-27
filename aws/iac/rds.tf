module "rds" {
  source = "./modules/rds"

  identifier              = "the-plug-db"
  engine                  = "postgres"
  engine_version          = "17.4"
  parameters_group_family = "postgres17"
  instance_class          = "db.t3.micro"
  allocated_storage       = 20
  storage_type            = "gp2"
  db_name                 = "postgres"
  username                = "plug"
  password                = module.secrets_rds.initial_value
  port                    = 5432
  subnet_ids              = module.vpc.private_subnet_ids
  backup_retention_period = 1
  backup_window           = "02:00-03:00"
  maintenance_window      = "Sun:03:00-Sun:04:00"

  parameters = []

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
      description     = "Database access on port 5432"
      protocol        = "tcp"
      security_groups = [module.elasticache.security_group_id, module.asg.security_group_id]
    }
  ]

  egress_rules = [
    {
      description = "Outbound HTTPS"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
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
  override_special = "!&#$^<>-"
}

module "secrets_rds" {
  source = "./modules/ssm-secret-parameter"

  name              = "rds-password"
  description       = "Password for RDS database"
  initial_value     = random_password.rds_password.result

  tags = {
    Environment = "dev"
  }

  depends_on = [random_password.rds_password]
}

data "aws_iam_policy_document" "rds_access_policy" {
  statement {
    effect    = "Allow"
    actions   = ["ssm:GetParameter"]
    resources = [module.secrets_rds.arn]
    principals {
      type        = "Service"
      identifiers = ["rds.amazonaws.com"]
    }
  }
}

resource "aws_iam_policy" "rds_access" {
  name = "rds-ssm-access-policy"
  description = "Allow RDS to access SSM secret parameter"
  policy = data.aws_iam_policy_document.rds_access_policy.json
}