variable "resource_group_name" {
  type        = string
  description = "Front Door resource group name"
}

variable "name" {
  type        = string
  description = "Front Door name"
  default     = "the-plug-front-door"
}

variable "custom_domain" {
  type        = string
  description = "Front Door custom domain name"
  default     = "theplug.software"
}

variable "zone_id" {
  type        = string
  description = "DNS Zone ID"
}

variable "zone_name" {
  type        = string
  description = "DNS Zone name"
}

variable "frontend_healthcheck_interval" {
  type        = number
  description = "Frontend healthcheck interval"
  default     = 60
}

variable "api_healthcheck_interval" {
  type        = number
  description = "API healthcheck interval"
  default     = 60
}

variable "api_healthcheck_endpoint" {
  type        = string
  description = "API healthcheck endpoint path"
  default     = "/api/herb/list/"
}

variable "blob_host" {
  type        = string
  description = "Frontend blob storage hostname"
}

variable "aks_backend_host" {
  type        = string
  description = "AKS backend API hostname"
}

variable "frontend_port" {
  type        = number
  description = "Frontend port"
  default     = 80
}

variable "api_port" {
  type        = number
  description = "API port"
  default     = 8080
}

variable "storage_endpoint" {
  type        = string
  description = "Frontend Blob Storage container hostname"
}

variable "aks_host" {
  type        = string
  description = "AKS public entrypoint hostname"
}

variable "tags" {
  description = "Resource tag map"
  type        = map(string)
  default     = {}
}