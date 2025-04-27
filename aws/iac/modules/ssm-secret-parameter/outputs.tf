output "arn" {
  description = "Secret parameter ARN"
  value       = aws_ssm_parameter.this.arn
}

output "name" {
  description = "Secret parameter name"
  value       = aws_ssm_parameter.this.name
}

output "kms_key_arn" {
  description = "Used KMS key ARN"
  value       = aws_ssm_parameter.this.key_id
}

output "initial_value" {
  description = "Secret parameter value (sensitive!)"
  value       = aws_ssm_parameter.this.value
  sensitive   = true
}