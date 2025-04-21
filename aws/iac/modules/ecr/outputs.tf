output "arn" {
  description = "Repository ARN"
  value       = aws_ecr_repository.this.arn
}

output "registry_id" {
  description = "Registry ID"
  value       = aws_ecr_repository.this.registry_id
}

output "repository_url" {
  description = "Repository URL"
  value       = aws_ecr_repository.this.repository_url
}

output "name" {
  description = "Repository name"
  value       = aws_ecr_repository.this.name
}