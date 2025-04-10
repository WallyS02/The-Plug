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
  kms_key_id                 = null
  auth_token                 = var.auth_token
  automatic_failover_enabled = false
  multi_az_enabled           = false
  num_cache_clusters         = 1
  snapshot_retention_limit   = 0
  maintenance_window         = var.maintenance_window
  auto_minor_version_upgrade = true

  tags = merge(var.tags, {
    Name = var.name
  })
}

# CloudWatch alarms
resource "aws_cloudwatch_metric_alarm" "redis_high_evictions" {
  alarm_name          = "Redis-High-Evictions"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "Evictions"
  namespace           = "AWS/ElastiCache"
  period              = 300
  statistic           = "Average"
  threshold           = var.high_evictions_threshold
  dimensions = {
    CacheClusterId = aws_elasticache_replication_group.main.id
  }
  alarm_actions = [var.alarm_topic_arn]
}