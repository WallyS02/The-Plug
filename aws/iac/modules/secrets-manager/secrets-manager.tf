# Secret creation
resource "aws_secretsmanager_secret" "this" {
  name        = var.name
  description = var.description
  kms_key_id  = coalesce(var.kms_key_arn, module.kms[0].key_arn)
}

# Secret init
resource "aws_secretsmanager_secret_version" "initial" {
  count         = var.initial_value != null ? 1 : 0
  secret_id     = aws_secretsmanager_secret.this.id
  secret_string = var.initial_value
}

# Secret rotation
resource "aws_secretsmanager_secret_rotation" "this" {
  count               = var.rotation_enabled ? 1 : 0
  secret_id           = aws_secretsmanager_secret.this.id
  rotation_lambda_arn = var.rotation_lambda_arn

  rotation_rules {
    automatically_after_days = var.rotation_interval
  }
}

# Secret policy
resource "aws_secretsmanager_secret_policy" "this" {
  policy     = var.policy
  secret_arn = aws_secretsmanager_secret.this.arn
}

module "kms" {
  count  = var.kms_key_arn == null ? 1 : 0
  source = "../kms"

  description = "KMS key for Secrets Manager ${var.name}"
  alias_name  = "secrets/${var.name}"
}