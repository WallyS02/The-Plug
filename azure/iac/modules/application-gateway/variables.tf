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
  description = "Backends request timeout"
  default     = 30
}

variable "blob_host" {
  type        = string
  description = "Frontend blob storage hostname"
}

variable "aks_backend_host" {
  type        = string
  description = "AKS backend API hostname"
}

variable "api_port" {
  type        = number
  description = "API port"
  default     = 8080
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