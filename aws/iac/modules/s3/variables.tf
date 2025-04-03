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

  validation {
    condition     = !var.mfa_delete_enabled || var.versioning_enabled
    error_message = "MFA delete requires versioning to be enabled"
  }
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

  validation {
    condition     = !var.logging_enabled || var.logging_target_bucket != null
    error_message = "Target bucket must be specified when logging is enabled"
  }
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
    transitions = list(object({
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
    rules = map(object({
      status                  = string
      priority                = number
      prefix                  = string
      destination_bucket_arn = string
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