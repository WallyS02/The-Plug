variable "resource_group_name" {
  type        = string
  description = "Resource Group name"
}

variable "location" {
  type        = string
  description = "Azure Region"
  default     = "polandcentral"
}

variable "vnet_name" {
  type        = string
  description = "Virtual Network name"
  default     = "the-plug"
}

variable "address_space" {
  type        = list(string)
  description = "VNet CIDR IP address list"
  default     = ["10.0.0.0/16"]
}

variable "public_subnet_prefix" {
  type        = string
  description = "Public subnet A CIDR"
  default     = "10.0.1.0/24"
}

variable "private_subnet_prefix" {
  type        = string
  description = "Private subnet CIDR"
  default     = "10.0.2.0/24"
}

variable "nat_gateway_sku" {
  type        = string
  description = "NAT Gateway SKU"
  default     = "Standard"
}

variable "public_ip_sku" {
  type        = string
  description = "NAT Gateway Public IP SKU"
  default     = "Standard"
}

variable "redis_id" {
  type        = string
  description = "Redis server ID"
}

variable "postgres_id" {
  type        = string
  description = "PostgreSQL server ID"
}

variable "redis_private_link_hostname" {
  type        = string
  description = "Redis private link hostname"
  default     = "privatelink.redis.cache.windows.net"
}

variable "postgres_private_link_hostname" {
  type        = string
  description = "PostgreSQL private link hostname ID"
  default     = "privatelink.postgres.db.windows.net"
}

variable "tags" {
  description = "Resource tag map"
  type        = map(string)
  default     = {}
}