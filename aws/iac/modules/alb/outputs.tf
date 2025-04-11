output "arn" {
  description = "ALB ARN"
  value       = aws_lb.main.arn
}

output "dns_name" {
  description = "ALB DNS name"
  value       = aws_lb.main.dns_name
}

output "hosted_zone_id" {
  description = "ALB hosted zone ID"
  value       = aws_lb.main.zone_id
}

output "zone_id" {
  description = "ALB Zone ID"
  value       = aws_lb.main.zone_id
}

output "target_group_arn" {
  description = "Target Group ARN"
  value       = aws_lb_target_group.main.arn
}

output "security_group_id" {
  description = "ALB security group ID"
  value       = var.security_groups[0]
}