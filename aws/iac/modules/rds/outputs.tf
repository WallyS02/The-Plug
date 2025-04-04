output "endpoint" {
  description = "Database endpoint"
  value       = aws_db_instance.main.endpoint
}

output "port" {
  description = "Database port"
  value       = aws_db_instance.main.port
}

output "identifier" {
  description = "RDS instance identifier"
  value = aws_db_instance.main.identifier
}

output "db_name" {
  description = "Database name"
  value = aws_db_instance.main.db_name
}