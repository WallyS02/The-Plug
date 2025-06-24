variable "resource_group_name" {
  type        = string
  description = "Resource group name"
}

variable "location" {
  type        = string
  description = "Azure Region"
  default     = "polandcentral"
}

variable "name" {
  type        = string
  description = "AGIC name"
  default     = "the-plug-agic"
}

variable "custom_domain" {
  type        = string
  description = "AGIC custom domain name"
  default     = "theplug.software"
}

variable "request_timeout" {
  type        = number
  description = "Backend request timeout"
  default     = 30
}

variable "subnet_id" {
  type        = string
  description = "AGIC subnet ID"
}

variable "tags" {
  description = "Resource tag map"
  type        = map(string)
  default     = {}
}