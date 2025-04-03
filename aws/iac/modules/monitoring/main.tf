# CloudWatch Alarm
resource "aws_cloudwatch_metric_alarm" "main" {
  for_each            = var.alarms
  alarm_name          = each.key
  comparison_operator = each.value.comparison_operator
  evaluation_periods  = each.value.evaluation_periods
  metric_name         = each.value.metric_name
  namespace           = each.value.namespace
  period              = each.value.period
  statistic           = each.value.statistic
  threshold           = each.value.threshold
  alarm_description   = each.value.description
  alarm_actions       = each.value.alarm_actions
  ok_actions          = each.value.ok_actions
  dimensions          = each.value.dimensions
  tags = merge(var.tags, {
    Name = each.key
  })
}

# CloudWatch Dashboard
resource "aws_cloudwatch_dashboard" "main" {
  count          = var.dashboard_config != null ? 1 : 0
  dashboard_body = jsonencode(var.dashboard_config)
  dashboard_name = var.dashboard_name
}

# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "main" {
  for_each          = var.log_groups
  name              = each.key
  retention_in_days = try(each.value.retention_in_days, null)
  kms_key_id        = try(each.value.kms_key_arn, null)
  tags = merge(var.tags, {
    Name = each.key
  })
}

# CloudWatch Metric Filter
resource "aws_cloudwatch_log_metric_filter" "main" {
  for_each       = var.metric_filters
  log_group_name = each.value.log_group_name
  name           = each.key
  pattern        = each.value.pattern

  metric_transformation {
    name      = each.value.metric_name
    namespace = each.value.metric_namespace
    value     = each.value.metric_value
  }
}

# IAM Role for CloudWatch Agent
resource "aws_iam_role" "cw_agent" {
  count = var.create_iam_role ? 1 : 0
  name  = "CloudWatchAgentRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "cw_agent" {
  count      = var.create_iam_role ? 1 : 0
  role       = aws_iam_role.cw_agent[0].name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}