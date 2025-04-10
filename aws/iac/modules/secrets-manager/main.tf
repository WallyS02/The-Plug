# Secret creation
resource "aws_secretsmanager_secret" "this" {
  name        = var.name
  description = var.description
  kms_key_id  = null

  tags = var.tags
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
  policy     = data.aws_iam_policy_document.policies.json
  secret_arn = aws_secretsmanager_secret.this.arn
}

data "aws_iam_policy_document" "policies" {
  statement {
    effect    = "Deny"
    actions   = ["secretsmanager:*"]
    resources = ["*"]
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    condition {
      test     = "Bool"
      variable = "aws:MultiFactorAuthPresent"
      values   = ["false"]
    }
  }

  dynamic "statement" {
    for_each = [for s in var.policy_statements : jsondecode(s)]
    content {
      sid       = lookup(statement.value, "Sid", null)
      effect    = statement.value["Effect"]
      actions   = statement.value["Action"]
      resources = [aws_secretsmanager_secret.this.arn]
      principals {
        type        = keys(statement.value["Principal"])[0]
        identifiers = values(statement.value["Principal"])[0]
      }
    }
  }
}