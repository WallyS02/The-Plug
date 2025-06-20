variable "resource_group_name" {
  type        = string
  description = "Resource Group name"
}

variable "location" {
  type        = string
  description = "Azure Region"
  default     = "polandcentral"
}

variable "storage_account_name" {
  type        = string
  description = "Storage Account name"
  default     = "the-plug"
}

variable "sku_tier" {
  type        = string
  description = "SKU account tier"
  default     = "Standard"
}

variable "account_replication_type" {
  type        = string
  description = "Account replication type"
  default     = "LRS"
}

variable "access_tier" {
  type        = string
  description = "Access tier"
  default     = "Hot"
}

variable "tags" {
  description = "Resource tag map"
  type        = map(string)
  default     = {}
}