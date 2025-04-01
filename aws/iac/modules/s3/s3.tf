# Bucket configuration
resource "aws_s3_bucket" "this" {
  bucket              = var.bucket_name
  force_destroy       = var.force_destroy
  object_lock_enabled = var.object_lock_enabled
  tags                = merge(var.tags, { Name = var.bucket_name })
}

# Versioning
resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id
  versioning_configuration {
    status     = var.versioning_enabled ? "Enabled" : "Suspended"
    mfa_delete = var.mfa_delete_enabled ? "Enabled" : "Disabled"
  }
}

# Encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = var.encryption.kms_key_arn != null ? "aws:kms" : "AES256"
      kms_master_key_id = var.encryption.kms_key_arn
    }
    bucket_key_enabled = var.encryption.bucket_key_enabled
  }
}

# Logging
resource "aws_s3_bucket_logging" "this" {
  count         = var.logging_enabled ? 1 : 0
  bucket        = aws_s3_bucket.this.id
  target_bucket = var.logging_target_bucket
  target_prefix = var.logging_prefix
}

# Public Access Block
resource "aws_s3_bucket_public_access_block" "this" {
  bucket                  = aws_s3_bucket.this.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Lifecycle Rules
resource "aws_s3_bucket_lifecycle_configuration" "this" {
  count  = length(var.lifecycle_rules) > 0 ? 1 : 0
  bucket = aws_s3_bucket.this.id

  dynamic "rule" {
    for_each = var.lifecycle_rules
    content {
      id     = rule.key
      status = rule.value.enabled ? "Enabled" : "Disabled"

      filter {
        prefix = rule.value.prefix
      }

      dynamic "transition" {
        for_each = rule.value.transistions
        content {
          days          = transition.value.days
          storage_class = transition.value.storage_class
        }
      }

      dynamic "expiration" {
        for_each = rule.value.expiration_days != null ? [1] : []
        content {
          days = rule.value.expiration_days
        }
      }

      noncurrent_version_expiration {
        noncurrent_days = rule.value.noncurrent_version_expiration_days
      }
    }
  }
}

# Interregional replication
resource "aws_s3_bucket_replication_configuration" "this" {
  count  = var.replication_config != null ? 1 : 0
  bucket = aws_s3_bucket.this.id
  role   = var.replication_config.iam_role_arn

  dynamic "rule" {
    for_each = var.replication_config.rules
    content {
      id       = rule.key
      status   = rule.value.status
      priority = rule.value.priority

      filter {
        prefix = rule.value.prefix
      }

      destination {
        bucket        = rule.value.destintation_bucket_arn
        storage_class = rule.value.storage_class
      }
    }
  }

  depends_on = [aws_s3_bucket_versioning.this]
}

# Static website configuration
resource "aws_s3_bucket_website_configuration" "this" {
  count  = var.website_config != null ? 1 : 0
  bucket = aws_s3_bucket.this.id

  index_document {
    suffix = var.website_config.index_document
  }

  error_document {
    key = var.website_config.error_document
  }

  dynamic "routing_rule" {
    for_each = var.website_config.routing_rules
    content {
      condition {
        key_prefix_equals = routing_rule.value.condition
      }
      redirect {
        replace_key_prefix_with = routing_rule.value.redirect
      }
    }
  }
}

# Bucket policy
resource "aws_s3_bucket_policy" "this" {
  count  = var.bucket_policy != null ? 1 : 0
  bucket = aws_s3_bucket.this.id
  policy = var.bucket_policy
}