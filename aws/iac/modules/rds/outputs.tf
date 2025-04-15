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
  value       = aws_db_instance.main.identifier
}

output "db_name" {
  description = "Database name"
  value       = aws_db_instance.main.db_name
}

output "low_storage_alarm_arn" {
  description = "Low Storage Alarm ARN"
  value       = aws_cloudwatch_metric_alarm.rds_low_storage.arn
}

output "user" {
  description = "Database username"
  value       = aws_db_instance.main.username
}

output "security_group_id" {
  description = "Database security group id"
  value       = var.rds_security_group[0]
}