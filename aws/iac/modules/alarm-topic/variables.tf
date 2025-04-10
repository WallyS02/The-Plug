variable "name_suffix" {
  description = "Suffix alarm topic name"
  type        = string
  default     = "default"
}

variable "email" {
  description = "Email to send to alarm messages"
  type        = string
  sensitive   = true

  validation {
    condition     = can(regex("^[^@]+@[^@]+$", var.email))
    error_message = "The email provided is not a valid email address"
  }
}

variable "tags" {
  description = "Resource tag map"
  type        = map(string)
  default     = {}
}