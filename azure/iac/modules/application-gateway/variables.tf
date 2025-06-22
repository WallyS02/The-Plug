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
  description = "Application Gateway name"
  default     = "the-plug-application-gateway"
}

variable "custom_domain" {
  type        = string
  description = "Application Gateway custom domain name"
  default     = "theplug.software"
}

variable "request_timeout" {
  type        = number
  description = "Backend request timeout"
  default     = 30
}

variable "blob_host" {
  type        = string
  description = "Frontend blob storage hostname"
}

variable "key_vault_id" {
  type        = string
  description = "Key Vault ID"
}

variable "key_vault_certificate_secret_id" {
  type        = string
  description = "Key Vault certificate secret ID"
}

variable "subnet_id" {
  type        = string
  description = "Application Gateway subnet ID"
}

variable "tags" {
  description = "Resource tag map"
  type        = map(string)
  default     = {}
}