# Redis subnet group configuration
resource "aws_elasticache_subnet_group" "main" {
  name       = "${var.name}-subnet-group"
  subnet_ids = var.subnet_ids
  tags       = var.tags
}

# Redis parameter group configuration
resource "aws_elasticache_parameter_group" "main" {
  family      = var.redis_family
  name        = "${var.name}-param-group"
  description = "Custom parameter group for ${var.name}"

  dynamic "parameter" {
    for_each = var.redis_parameters
    content {
      name  = parameter.value.name
      value = parameter.value.value
    }
  }
}

# Redis replication group configuration
resource "aws_elasticache_replication_group" "main" {
  replication_group_id       = var.name
  description                = "Redis cluster for ${var.name}"
  node_type                  = var.node_type
  port                       = var.port
  parameter_group_name       = aws_elasticache_parameter_group.main.name
  security_group_ids         = var.redis_security_group
  subnet_group_name          = aws_elasticache_subnet_group.main.name
  engine_version             = var.redis_version
  at_rest_encryption_enabled = var.encryption_at_rest
  transit_encryption_enabled = var.encryption_in_transit
  kms_key_id                 = var.kms_key_arn
  auth_token                 = var.auth_token
  automatic_failover_enabled = var.multi_az
  multi_az_enabled           = var.multi_az
  num_cache_clusters         = var.multi_az ? 2 : 1
  snapshot_retention_limit   = var.snapshot_retention_days
  maintenance_window         = var.maintenance_window
  snapshot_window            = var.snapshot_window

  tags = merge(var.tags, {
    Name = var.name
  })
}