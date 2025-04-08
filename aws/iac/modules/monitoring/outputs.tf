output "cw_agent_role_arn" {
  description = "CloudWatch Agent IAM role ARN"
  value       = try(aws_iam_role.cw_agent[0].arn, null)
}