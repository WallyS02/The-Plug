output "asg_name" {
  description = "Auto Scaling Group name"
  value       = aws_autoscaling_group.main.name
}

output "asg_arn" {
  description = "Auto Scaling Group ARN"
  value       = aws_autoscaling_group.main.arn
}

output "launch_template_id" {
  description = "Launch Template ID"
  value       = aws_launch_template.main.id
}

output "launch_template_latest_version" {
  description = "Launch Template latest version"
  value       = aws_launch_template.main.latest_version
}

output "name_prefix" {
  description = "Name prefix used for ASG"
  value       = var.name_prefix
}

output "ec2_role_arn" {
  description = "ARN of role used in EC2 instances in ASG"
  value       = aws_iam_role.ec2_instance_role.arn
}

output "security_group_id" {
  description = "ASG Security Group ID"
  value       = aws_launch_template.main.vpc_security_group_ids
}