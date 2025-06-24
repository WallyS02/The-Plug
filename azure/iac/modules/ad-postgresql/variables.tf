variable "resource_group_name" {
  description = "Resource Group name"
  type        = string
}

variable "location" {
  description = "Azure Region"
  type        = string
  default     = "polandcentral"
}

variable "postgres_name" {
  description = "PostgreSQL name"
  type        = string
  default     = "the-plug"
}

variable "sku_name" {
  description = "PostgreSQL server SKU"
  type        = string
  default     = "B_Standard_B1ms"
}

variable "storage_mb" {
  description = "Disk capacity in MB"
  type        = number
  default     = 32768 # 32 GB
}

variable "administrator_login" {
  description = "Database administrator login"
  type        = string
}

variable "administrator_password" {
  description = "Database administrator password"
  type        = string
  sensitive   = true
}

variable "postgresql_version" {
  description = "PostgreSQL version"
  type        = string
  default     = "16"
}

variable "tags" {
  description = "Resource tag map"
  type        = map(string)
  default     = {}
}