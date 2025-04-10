variable "name" {
  description = "Secret name"
  type        = string
}

variable "description" {
  description = "Secret description"
  type        = string
  default     = "Secret managed by Terraform"
}

variable "initial_value" {
  description = "Initial secret value (sensitive!)"
  type        = string
  default     = null
  sensitive   = true
}

variable "rotation_enabled" {
  description = "Enable automatic rotation?"
  type        = bool
  default     = false
}

variable "rotation_lambda_arn" {
  description = "Rotation function Lambda ARN"
  type        = string
  default     = null
}

variable "rotation_interval" {
  description = "Rotation interval in days"
  type        = number
  default     = 30

  validation {
    condition     = var.rotation_interval >= 7 && var.rotation_interval <= 365
    error_message = "Rotation period must be between 7 and 365 days"
  }
}

variable "policy_statements" {
  description = "Additional access policies in JSON format"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Resource tag map"
  type        = map(string)
  default     = {}
}