# Log groups
resource "aws_cloudwatch_log_group" "ecs" {
  name              = "/ecs/the-plug" # TODO change after ECS creation
  retention_in_days = 1
}

resource "aws_cloudwatch_log_group" "rds" {
  name              = "/aws/rds/${module.rds.identifier}/${module.rds.db_name}"
  retention_in_days = 1
}

resource "aws_cloudwatch_log_group" "cloudfront" {
  name              = "/aws/cloudfront/${module.cloudfront.distribution_id}"
  retention_in_days = 1
}

# CloudFront log storage size exceeded alarm
resource "aws_cloudwatch_metric_alarm" "cloudfront_log_size" {
  alarm_name          = "${aws_cloudwatch_log_group.cloudfront.name}-Size-Alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "StoredBytes"
  namespace           = "AWS/Logs"
  period              = 86400 # 24h
  statistic           = "Maximum"
  threshold           = 4.5e9 # 4.5 GB
  alarm_description   = "Log group approaching 5GB limit"
  alarm_actions       = [module.alarm_topic.arn]
  dimensions = {
    LogGroupName = aws_cloudwatch_log_group.cloudfront.name
  }
}