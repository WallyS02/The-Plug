variable "resource_group_name" {
  type        = string
  description = "Resource Group name"
}

variable "location" {
  type        = string
  description = "Azure Region"
  default     = "polandcentral"
}

variable "keyvault_name" {
  type        = string
  description = "Key Vault name"
  default     = "the-plug"
}

variable "tenant_id" {
  type        = string
  description = "Azure Tenant ID (Entra ID)"
}

variable "object_id" {
  type        = string
  description = "Azure Object ID (Entra ID)"
}

variable "subnet_ids" {
  type        = list(string)
  description = "Subnet ID list Lista with access to Key Vault"
  default     = []
}

variable "tags" {
  description = "Resource tag map"
  type        = map(string)
  default     = {}
}