module "s3_frontend_bucket" {
  source = "./modules/s3"

  bucket_name         = "frontend-bucket"
  versioning_enabled  = true
  mfa_delete_enabled  = false
  force_destroy       = true
  object_lock_enabled = false

  logging_enabled = false
  lifecycle_rules = {}

  website_config = null

  tags = {
    Environment = "dev"
  }
}