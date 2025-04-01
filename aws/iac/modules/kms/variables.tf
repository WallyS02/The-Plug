variable "description" {
  description = "Key description"
  type        = string
  default     = "Key managed by Terraform"
}

variable "enable_key_rotation" {
  description = "Enable automatic key rotation?"
  type        = bool
  default     = true
}

variable "deletion_window_in_days" {
  description = "Deletion window before key deletion (7-30 days)"
  type        = number
  default     = 30

  validation {
    condition     = var.deletion_window_in_days >= 7 && var.deletion_window_in_days <= 30
    error_message = "Deletion window must be between 7 and 30 days"
  }
}

variable "kms_policy" {
  description = "Key root permissions IAM policy and additional IAM policies list in JSON format"
  type        = string
  default     = ""
}

variable "alias_name" {
  description = "Alias name (without 'alias/' prefix)"
  type        = string
  default     = null
}

variable "is_enabled" {
  description = "Enable key?"
  type        = bool
  default     = true
}

variable "multi-region" {
  description = "Create multi-regional key?"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Resource tag map"
  type        = map(string)
  default     = {}
}