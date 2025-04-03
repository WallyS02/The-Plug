output "arn" {
  description = "S3 bucket ARN"
  value       = aws_s3_bucket.this.arn
}

output "id" {
  description = "S3 bucket ID"
  value = aws_s3_bucket.this.id
}

output "name" {
  description = "Bucket name"
  value       = aws_s3_bucket.this.bucket
}

output "regional_domain_name" {
  description = "Regional domain name"
  value       = aws_s3_bucket.this.bucket_regional_domain_name
}

output "website_endpoint" {
  description = "Static website endpoint"
  value       = try(aws_s3_bucket_website_configuration.this[0].website_endpoint, null)
}

output "logs_prefix" {
  description = "Log prefix"
  value       = var.logging_prefix
}