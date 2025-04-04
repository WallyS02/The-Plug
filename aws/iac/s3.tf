module "s3_frontend_bucket" {
  source = "./modules/s3"

  bucket_name         = "frontend-bucket"
  versioning_enabled  = true
  mfa_delete_enabled  = false
  force_destroy       = false
  object_lock_enabled = true

  bucket_policy   = null
  logging_enabled = false
  lifecycle_rules = {}

  website_config = {
    index_document = "index.html"
    error_document = "error.html"
    routing_rules  = []
  }
}