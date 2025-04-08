output "cluster_name" {
  description = "ECS cluster name"
  value       = aws_ecs_cluster.main.name
}

output "name" {
  description = "ECS name"
  value       = var.name
}

output "ecs_no_tasks_alarm_arn" {
  description = "ECS no tasks alarm ARN"
  value       = aws_cloudwatch_metric_alarm.ecs_no_tasks.arn
}