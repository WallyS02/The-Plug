# ECR configuration
resource "aws_ecr_repository" "this" {
  name                 = var.name
  image_tag_mutability = var.image_tag_mutability
  tags                 = var.tags

  image_scanning_configuration {
    scan_on_push = var.scan_on_push
  }

  encryption_configuration {
    encryption_type = var.encryption_type
    kms_key         = var.encryption_type == "KMS" ? var.kms_key : null
  }
}

# ECR lifecycle policy
resource "aws_ecr_lifecycle_policy" "this" {
  count      = var.lifecycle_policy != null ? 1 : 0
  policy     = var.lifecycle_policy
  repository = aws_ecr_repository.this.name
}

# ECR repository policy
resource "aws_ecr_repository_policy" "this" {
  count      = var.repository_policy != null ? 1 : 0
  policy     = var.repository_policy
  repository = aws_ecr_repository.this.name
}