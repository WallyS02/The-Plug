variable "resource_group_name" {
  type        = string
  description = "Resource Group name"
}

variable "location" {
  type        = string
  description = "Azure Region"
  default     = "polandcentral"
}

variable "acr_name" {
  type        = string
  description = "Azure Container Registry name"
  default     = "theplug"
}

variable "sku" {
  type        = string
  description = "ACR SKU"
  default     = "Basic"
}

variable "admin_enabled" {
  type        = bool
  description = "Enable admin account?"
  default     = false
}

variable "tags" {
  description = "Resource tag map"
  type        = map(string)
  default     = {}
}