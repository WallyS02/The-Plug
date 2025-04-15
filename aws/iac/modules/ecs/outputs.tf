output "cluster_name" {
  description = "ECS cluster name"
  value       = aws_ecs_cluster.main.name
}

output "name" {
  description = "ECS name"
  value       = var.name
}