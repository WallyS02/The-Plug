variable "name" {
  description = "ECR repository name"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9]+(?:[._-][a-z0-9]+)*$", var.name))
    error_message = "Name must meet ECR requirements: lowercase letters, numbers, and ._- characters"
  }
}

variable "scan_on_push" {
  description = "Scan images on push?"
  type        = bool
  default     = true
}

variable "image_tag_mutability" {
  description = "Mutability of image tags (MUTABLE/IMMUTABLE)"
  type        = string
  default     = "IMMUTABLE"

  validation {
    condition     = contains(["MUTABLE", "IMMUTABLE"], var.image_tag_mutability)
    error_message = "Allowed values: MUTABLE, IMMUTABLE"
  }
}

variable "encryption_type" {
  description = "Encryption type (AES256/KMS)"
  type        = string
  default     = "AES256"

  validation {
    condition     = contains(["AES256", "KMS"], var.encryption_type)
    error_message = "Allowed values: AES256, KMS"
  }
}

variable "kms_key" {
  description = "KMS key ARN (if encryption_type = KMS)"
  type        = string
  default     = null
}

variable "lifecycle_policy" {
  description = "Lifecycle policy in JSON format"
  type        = string
  default     = null
}

variable "repository_policy" {
  description = "Access policy in JSON format"
  type        = string
  default     = null
}

variable "tags" {
  description = "Resource tag map"
  type        = map(string)
  default     = {}
}