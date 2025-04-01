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
  value       = coalesce(var.kms_key_arn, try(module.kms[0].key_arn, null))
}

output "rotation_enabled" {
  description = "Is rotation enabled?"
  value       = var.rotation_enabled
}