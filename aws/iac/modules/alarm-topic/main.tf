resource "aws_sns_topic" "alarm_topic" {
  name         = "alarm-topic-${var.name_suffix}"
  display_name = "Alarm Notifications Topic"
  tags         = var.tags
}

resource "aws_sns_topic_subscription" "alarm_topic_subscription" {
  topic_arn = aws_sns_topic.alarm_topic.arn
  protocol  = "email"
  endpoint  = var.email

  lifecycle {
    ignore_changes = [endpoint]
  }
}