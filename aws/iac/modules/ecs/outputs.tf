output "cluster_name" {
  description = "ECS cluster name"
  value       = aws_ecs_cluster.main.name
}

output "name" {
  description = "ECS name"
  value       = var.name
}

output "execution_role_arn" {
  description = "Execution role ARN"
  value       = aws_iam_role.ecs_execution_role.arn
}