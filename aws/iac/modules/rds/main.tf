# RDS subnet group configuration
resource "aws_db_subnet_group" "main" {
  name       = "${var.identifier}-subnet-group"
  subnet_ids = var.subnet_ids
  tags = merge(var.tags, {
    Name = "${var.identifier}-subnet-group"
  })
}

# RDS parameter group configuration
resource "aws_db_parameter_group" "main" {
  name        = "${var.identifier}-parameter-group"
  family      = var.parameters_group_family
  description = "Custom parameter group for ${var.identifier}"

  dynamic "parameter" {
    for_each = var.parameters
    content {
      name         = parameter.value.name
      value        = parameter.value.value
      apply_method = parameter.value.apply_method
    }
  }

  tags = var.tags
}

# RDS instance configuration
resource "aws_db_instance" "main" {
  identifier        = var.identifier
  engine            = var.engine
  engine_version    = var.engine_version
  instance_class    = var.instance_class
  allocated_storage = var.allocated_storage
  storage_type      = var.storage_type
  storage_encrypted = true
  kms_key_id        = null
  license_model     = var.license_model

  db_name  = var.db_name
  username = var.username
  password = var.password
  port     = var.port

  publicly_accessible        = false
  db_subnet_group_name       = aws_db_subnet_group.main.name
  vpc_security_group_ids     = var.rds_security_group
  parameter_group_name       = aws_db_parameter_group.main.name
  auto_minor_version_upgrade = true

  backup_retention_period   = var.backup_retention_period
  backup_window             = var.backup_window
  maintenance_window        = var.maintenance_window
  deletion_protection       = var.deletion_protection
  skip_final_snapshot       = var.skip_final_snapshot
  final_snapshot_identifier = var.final_snapshot_identifier

  performance_insights_enabled          = var.performance_insights_enabled
  performance_insights_retention_period = var.performance_insights_retention_period

  enabled_cloudwatch_logs_exports = var.cloud_watch_log_exports

  tags = merge(var.tags, {
    Name = var.identifier
  })
}

# CloudWatch alarms
resource "aws_cloudwatch_metric_alarm" "rds_low_storage" {
  alarm_name          = "RDS-Low-Storage"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 2
  metric_name         = "FreeStorageSpace"
  namespace           = "AWS/RDS"
  period              = 3600
  statistic           = "Minimum"
  threshold           = var.low_storage_threshold
  dimensions = {
    DBInstanceIdentifier = aws_db_instance.main.identifier
  }
  alarm_actions = [var.alarm_topic_arn]

  tags = var.tags
}

resource "aws_cloudwatch_metric_alarm" "rds_high_connections" {
  alarm_name          = "RDS-High-Connections"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "DatabaseConnections"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = var.high_connections_amount
  dimensions = {
    DBInstanceIdentifier = aws_db_instance.main.identifier
  }
  alarm_actions = [var.alarm_topic_arn]

  tags = var.tags
}