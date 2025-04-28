variable "name" {
  description = "Secret parameter name"
  type        = string
}

variable "description" {
  description = "Secret parameter description"
  type        = string
  default     = "Secret parameter managed by Terraform"
}

variable "initial_value" {
  description = "Initial secret parameter value (sensitive!)"
  type        = string
  default     = null
  sensitive   = true
}

variable "tags" {
  description = "Resource tag map"
  type        = map(string)
  default     = {}
}