output "primary_endpoint" {
  description = "Redis primary endpoint"
  value       = aws_elasticache_replication_group.main.primary_endpoint_address
}

output "configuration_endpoint" {
  description = "Configuration endpoint (for cluster mode)"
  value       = try(aws_elasticache_replication_group.main.configuration_endpoint_address, null)
}

output "port" {
  description = "Redis port"
  value       = aws_elasticache_replication_group.main.port
}

output "arn" {
  description = "Redis ARN"
  value       = aws_elasticache_replication_group.main.arn
}