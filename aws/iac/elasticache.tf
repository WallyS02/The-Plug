module "elasticache" {
  source = "./modules/elasticache"

  name                  = "the-plug-cache"
  subnet_ids            = module.vpc.private_subnet_ids
  node_type             = "cache.t3.micro"
  redis_version         = "7.1"
  port                  = 6379
  encryption_at_rest    = true
  encryption_in_transit = true
  auth_token            = module.secrets_elasticache.initial_value
  maintenance_window    = "sun:02:00-sun:03:00"
  redis_security_group  = [module.elasticache_security_group.id]

  redis_parameters = [
    { name = "maxmemory-policy", value = "volatile-lru" }
  ]

  tags = {
    Environment = "dev"
  }
}

module "elasticache_security_group" {
  source = "./modules/security-groups"

  name        = "elasticache-security-group"
  description = "Security group for Elasticache in private subnet"
  vpc_id      = module.vpc.vpc_id

  ingress_rules = [
    {
      from_port       = 6379
      to_port         = 6379
      description     = "Redis cache access on port 6379"
      protocol        = "tcp"
      security_groups = [module.asg.security_group_id]
    }
  ]

  egress_rules = []
}

resource "aws_security_group_rule" "elasticache_database_access" {
  type                     = "egress"
  description              = "Database access"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  source_security_group_id = module.rds.security_group_id
  security_group_id        = module.elasticache_security_group.id
}

resource "aws_security_group_rule" "elasticache_outbound_HTTPS" {
  type              = "egress"
  description       = "Outbound HTTPS"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.elasticache_security_group.id
}

resource "random_password" "elasticache_password" {
  length           = 16
  min_upper        = 1
  min_lower        = 1
  min_numeric      = 1
  override_special = "!&#$^<>-"
}

module "secrets_elasticache" {
  source = "./modules/ssm-secret-parameter"

  name          = "elasticache-auth-token"
  description   = "Auth token for Elasticache"
  initial_value = random_password.elasticache_password.result

  tags = {
    Environment = "dev"
  }

  depends_on = [random_password.elasticache_password]
}