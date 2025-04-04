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
}

variable "recovery_window" {
  description = "Recovery window before deletion in days (7-30 days)"
  type        = number
  default     = 30

  validation {
    condition     = var.recovery_window >= 7 && var.recovery_window <= 30
    error_message = "Recovery window must be between 7 and 30 days"
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