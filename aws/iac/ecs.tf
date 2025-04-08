module "ecs" {
  source = "./modules/ecs"

  name                           = "the-plug"
  container_name                 = "the-plug-backend"
  ecr_repository_url             = module.ecr.repository_url
  image_tag                      = "latest"
  container_port                 = 8080
  host_port                      = 8080
  target_group_arn               = module.alb.target_group_arn
  alarm_topic_arn                = module.alarm_topic.arn
  db_endpoint                    = module.rds.endpoint
  db_name                        = module.rds.db_name
  db_user                        = module.rds.user
  db_password_secret_arn         = module.secrets_rds.arn
  email_host_password_secret_arn = module.email_host_password_secret.arn
  email_host_user_secret_arn     = module.email_host_user_secret.arn
  secret_key_secret_arn          = module.secret_key_secret.arn
}

module "email_host_password_secret" {
  source = "./modules/secrets-manager"

  name             = "email-host-password"
  description      = "Email host password for ECS"
  initial_value    = var.email_host_password_secret # use .tfvars file
  rotation_enabled = false
  policy_statements = [
    data.aws_iam_policy_document.ecs_access.json
  ]
}

module "email_host_user_secret" {
  source = "./modules/secrets-manager"

  name             = "email-host-user"
  description      = "Email host user for ECS"
  initial_value    = var.email_host_user_secret # use .tfvars file
  rotation_enabled = false
  policy_statements = [
    data.aws_iam_policy_document.ecs_access.json
  ]
}

module "secret_key_secret" {
  source = "./modules/secrets-manager"

  name             = "secret-key-secret"
  description      = "Secret Key for ECS"
  initial_value    = var.secret_key_secret # use .tfvars file
  rotation_enabled = false
  policy_statements = [
    data.aws_iam_policy_document.ecs_access.json
  ]
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
      identifiers = ["ecs.amazonaws.com"]
    }
  }
}