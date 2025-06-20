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
  default     = "B_Gen5_2"
}

variable "storage_mb" {
  description = "Disk capacity in MB"
  type        = number
  default     = 5120 # 5 GB
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

variable "version" {
  description = "PostgreSQL version"
  type        = string
  default     = "11"
}

variable "subnet_id" {
  description = "Vnet subnet ID, where server should be created"
  type        = string
}

variable "tags" {
  description = "Resource tag map"
  type        = map(string)
  default     = {}
}