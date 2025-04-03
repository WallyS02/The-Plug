module "elasticache" {
  source = "./modules/elasticache"

  name                    = "the-plug-cache"
  subnet_ids              = module.vpc.private_subnet_ids
  node_type               = "cache.t3.micro"
  redis_version           = "6.x"
  port                    = 6379
  multi_az                = false
  encryption_at_rest      = true
  encryption_in_transit   = true
  kms_key_arn             = module.kms_elasticache.key_arn
  auth_token              = module.secrets_elasticache.initial_value
  snapshot_retention_days = 7
  maintenance_window      = "sun:02:00-sun:03:00"
  snapshot_window         = "04:00-05:00"
  redis_security_group    = [module.elasticache_security_group.id]

  redis_parameters = []
}

module "elasticache_security_group" {
  source = "./modules/security-groups"

  name        = "elasticache-security-group"
  description = "Security group for Elasticache in private subnet"
  vpc_id      = module.vpc.vpc_id
  ingress_rules = [
    {
      from_port   = 6379
      to_port     = 6379
      description = "Allowing communication on port 6379"
      protocol    = "tcp"
      security_groups = [module.asg.security_group_id]
    }
  ]
}

module "kms_elasticache" {
  source = "./modules/kms"

  description         = "Key for Elasticache encryption"
  alias_name          = "elasticache"
  enable_key_rotation = false

  additional_policies = data.aws_iam_policy_document.elasticache_kms_policy.json
}

data "aws_iam_policy_document" "elasticache_kms_policy" {
  statement {
    sid    = "AllowElasticacheService"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["elasticache.amazonaws.com"]
    }
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:GenerateDataKey*"
    ]
    resources = ["*"]
  }
}

resource "random_password" "elasticache_password" {
  length  = 16
  special = true
}

module "secrets_elasticache" {
  source = "./modules/secrets-manager"

  name             = "elasticache-auth-token"
  description      = "Auth token for Elasticache"
  initial_value    = random_password.elasticache_password.result
  rotation_enabled = false
  recovery_window  = 7
  policy_statements = [
    data.aws_iam_policy_document.elasticache_access.json
  ]
}

data "aws_iam_policy_document" "elasticache_access" {
  statement {
    effect    = "Allow"
    actions   = ["secretsmanager:GetSecretValue"]
    resources = [module.secrets_elasticache.arn]
    principals {
      type        = "Service"
      identifiers = ["elasticache.amazonaws.com"]
    }
  }
}