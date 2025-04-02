output "alarm_arns" {
  description = "Alarms ARNs"
  value       = { for k, v in aws_cloudwatch_metric_alarm.main : k => v.arn }
}

output "log_group_arns" {
  description = "Log Groups ARNs"
  value       = { for k, v in aws_cloudwatch_log_group.main : k => v.arn }
}

output "dashboard_arn" {
  description = "Dashboard ARN"
  value       = try(aws_cloudwatch_dashboard.main[0].dashboard_arn, null)
}

output "cw_agent_role_arn" {
  description = "CloudWatch Agent IAM role ARN"
  value       = try(aws_iam_role.cw_agent[0].arn, null)
}