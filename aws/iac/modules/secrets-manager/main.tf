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
  count       = length(var.policy_statements) > 0 ? 1 : 0
  policy     = data.aws_iam_policy_document.combined[0].json
  secret_arn = aws_secretsmanager_secret.this.arn
}

module "kms" {
  count  = var.kms_key_arn == null ? 1 : 0
  source = "../kms"

  description = "KMS key for Secrets Manager ${var.name}"
  alias_name  = "secrets/${var.name}"
  additional_policies = data.aws_iam_policy_document.kms_policy.json
}

data "aws_iam_policy_document" "combined" {
  count = length(var.policy_statements) > 0 ? 1 : 0

  source_policy_documents = concat(
    [data.aws_iam_policy_document.default_policy.json],
    var.policy_statements
  )
}

data "aws_iam_policy_document" "default_policy" {
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
}

data "aws_iam_policy_document" "kms_policy" {
  statement {
    effect = "Allow"
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey"
    ]
    resources = ["*"]
    principals {
      type        = "Service"
      identifiers = ["secretsmanager.amazonaws.com"]
    }
  }
}