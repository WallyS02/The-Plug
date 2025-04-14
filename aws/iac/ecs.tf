module "ecs" {
  source = "./modules/ecs"

  name                 = "the-plug"
  container_name       = "the-plug-backend"
  ecr_repository_url   = module.ecr.repository_url
  image_tag            = "latest"
  container_port       = 8080
  target_group_arn     = module.alb.target_group_arn
  asg_arn              = module.asg.asg_arn
  task_subnets         = module.vpc.private_subnet_ids
  task_security_groups = [module.ecs_security_group.id]
  alarm_topic_arn      = module.alarm_topic.arn
  db_endpoint          = module.rds.endpoint
  # cache_endpoint                 = "redis://:${module.elasticache.auth_token}@${module.elasticache.primary_endpoint}:${module.elasticache.port}/1"
  cache_endpoint                 = "redis://${module.elasticache.primary_endpoint}:${module.elasticache.port}/1"
  db_name                        = module.rds.db_name
  db_user                        = module.rds.user
  db_password_secret_arn         = module.secrets_rds.arn
  email_host_password_secret_arn = module.email_host_password_secret.arn
  email_host_user_secret_arn     = module.email_host_user_secret.arn
  secret_key_secret_arn          = module.secret_key_secret.arn
  log_group                      = aws_cloudwatch_log_group.ecs.name
  log_region                     = var.region

  tags = {
    Evironment = "dev"
  }
}

module "ecs_security_group" {
  source = "./modules/security-groups"

  name        = "ecs-security-group"
  description = "Security group for ECS"
  vpc_id      = module.vpc.vpc_id

  ingress_rules = [
    {
      from_port       = 8080
      to_port         = 8080
      description     = "ALB access on port 8080"
      protocol        = "tcp"
      security_groups = [module.alb.security_group_id]
    }
  ]

  egress_rules = []

  tags = {
    Environment = "dev"
  }
}

resource "aws_security_group_rule" "ecs_database_access" {
  type                     = "egress"
  description              = "Database access"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  source_security_group_id = module.rds.security_group_id
  security_group_id        = module.ecs_security_group.id
}

resource "aws_security_group_rule" "ecs_cache_access" {
  type                     = "egress"
  description              = "Cache access"
  from_port                = 6379
  to_port                  = 6379
  protocol                 = "tcp"
  source_security_group_id = module.elasticache.security_group_id
  security_group_id        = module.ecs_security_group.id
}

resource "aws_security_group_rule" "ecs_outbound_HTTPS" {
  type              = "egress"
  description       = "Outbound HTTPS"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.ecs_security_group.id
}

module "email_host_password_secret" {
  source = "./modules/secrets-manager"

  name              = "email-host-password"
  description       = "Email host password for ECS"
  enable_init_value = true
  initial_value     = var.email_host_password_secret # use .tfvars file
  rotation_enabled  = false
  policy_statements = [
    data.aws_iam_policy_document.ecs_access.json
  ]

  tags = {
    Environment = "dev"
  }
}

module "email_host_user_secret" {
  source = "./modules/secrets-manager"

  name              = "email-host-user"
  description       = "Email host user for ECS"
  enable_init_value = true
  initial_value     = var.email_host_user_secret # use .tfvars file
  rotation_enabled  = false
  policy_statements = [
    data.aws_iam_policy_document.ecs_access.json
  ]

  tags = {
    Environment = "dev"
  }
}

module "secret_key_secret" {
  source = "./modules/secrets-manager"

  name              = "secret-key-secret"
  description       = "Secret Key for ECS"
  enable_init_value = true
  initial_value     = var.secret_key_secret # use .tfvars file
  rotation_enabled  = false
  policy_statements = [
    data.aws_iam_policy_document.ecs_access.json
  ]

  tags = {
    Environment = "dev"
  }
}

data "aws_iam_policy_document" "ecs_access" {
  statement {
    effect  = "Allow"
    actions = ["secretsmanager:GetSecretValue"]
    resources = [
      module.email_host_password_secret.arn,
      module.email_host_user_secret.arn,
      module.secret_key_secret.arn
    ]
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}