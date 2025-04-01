data "aws_caller_identity" "current" {}

# Key creation
resource "aws_kms_key" "this" {
  description             = var.description
  enable_key_rotation     = var.enable_key_rotation
  deletion_window_in_days = var.deletion_window_in_days
  policy                  = var.kms_policy
  is_enabled              = var.is_enabled
  multi_region            = var.multi-region
  tags                    = var.tags
}

# Key alias creation
resource "aws_kms_alias" "this" {
  count         = var.alias_name != null ? 1 : 0
  name          = "alias/${var.alias_name}"
  target_key_id = aws_kms_key.this.key_id
}