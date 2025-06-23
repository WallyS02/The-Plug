variable "resource_group_name" {
  type        = string
  description = "Resource Group name for DNS Zone"
}

variable "record_name" {
  type        = string
  description = "DNS record name"
  default     = "@"
}

variable "zone_name" {
  type        = string
  description = "DNS Zone name"
  default     = "theplug.software"
}

variable "application_gateway_ip_id" {
  type        = string
  description = "Application Gateway public IP address ID"
}

variable "tags" {
  description = "Resource tag map"
  type        = map(string)
  default     = {}
}