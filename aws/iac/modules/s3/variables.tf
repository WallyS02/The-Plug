variable "bucket_name" {
  description = "S3 bucket name"
  type        = string
}

variable "versioning_enabled" {
  description = "Enable versioning?"
  type        = bool
  default     = true
}

variable "mfa_delete_enabled" {
  description = "Require MFA to delete version?"
  type        = bool
  default     = false
}

variable "encryption" {
  description = "Encryption configuration"
  type = object({
    kms_key_arn        = optional(string)
    bucket_key_enabled = optional(bool, true)
  })
  default = {
    kms_key_arn        = null
    bucket_key_enabled = true
  }
}

variable "logging_enabled" {
  description = "Enable logging?"
  type        = bool
  default     = false
}

variable "logging_target_bucket" {
  description = "Log target bucket"
  type        = string
  default     = null
}

variable "logging_prefix" {
  description = "Log prefix"
  type        = string
  default     = "logs/"
}

variable "lifecycle_rules" {
  description = "Lifecycle rules"
  type = map(object({
    enabled = bool
    prefix  = string
    transistions = list(object({
      days          = number
      storage_class = string
    }))
    expiration_days                    = optional(number)
    noncurrent_version_expiration_days = number
  }))
  default = {}
}

variable "replication_config" {
  description = "Replication configuration"
  type = object({
    iam_role_arn = string
    rules = map(object({
      status                  = string
      priority                = number
      prefix                  = string
      destintation_bucket_arn = string
      storage_class           = string
    }))
  })
  default = null
}

variable "website_config" {
  description = "Static website configuration"
  type = object({
    index_document = string
    error_document = string
    routing_rules = list(object({
      condition = string
      redirect  = string
    }))
  })
  default = null
}

variable "bucket_policy" {
  description = "Bucket policy JSON"
  type        = string
  default     = null
}

variable "force_destroy" {
  description = "Forcefully destroy bucket with its contents?"
  type        = bool
  default     = false
}

variable "object_lock_enabled" {
  description = "Enable object lock?"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Resource tag map"
  type        = map(string)
  default     = {}
}