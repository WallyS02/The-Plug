output "arn" {
  description = "Secret ARN"
  value       = aws_secretsmanager_secret.this.arn
}

output "name" {
  description = "Secret name"
  value       = aws_secretsmanager_secret.this.name
}

output "kms_key_arn" {
  description = "Used KMS key ARN"
  value       = aws_secretsmanager_secret.this.kms_key_id
}

output "rotation_enabled" {
  description = "Is rotation enabled?"
  value       = var.rotation_enabled
}

output "initial_value" {
  description = "Secret initial value (sensitive!)"
  value       = aws_secretsmanager_secret_version.initial[0].secret_string
  sensitive   = true
}