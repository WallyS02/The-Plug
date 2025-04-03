module "s3_frontend_bucket" {
  source = "./modules/s3"

  bucket_name = "frontend-bucket"
  versioning_enabled = true
  mfa_delete_enabled = false
  force_destroy = false
  object_lock_enabled = true

  bucket_policy = null
  logging_enabled = false
  lifecycle_rules = {}
  replication_config = null

  encryption = {
    kms_key_arn = module.kms_s3.key_arn
    bucket_key_enabled = true
  }

  website_config = {
    index_document = "index.html"
    error_document = "error.html"
  }
}

module "kms_s3" {
  source = "./modules/kms"

  description         = "Key for S3 encryption"
  alias_name          = "s3"
  enable_key_rotation = false

  additional_policies = [
    data.aws_iam_policy_document.s3_kms_policy
  ]
}

data "aws_iam_policy_document" "s3_kms_policy" {
  statement {
    sid    = "AllowS3Use"
    effect = "Allow"
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey"
    ]
    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }
    resources = ["*"]
  }
}