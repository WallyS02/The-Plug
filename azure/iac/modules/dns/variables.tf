variable "resource_group_name" {
  type        = string
  description = "Resource Group name for DNS Zone"
}

variable "zone_name" {
  type        = string
  description = "DNS Zone name"
  default     = "the-plug"
}

variable "tags" {
  description = "Resource tag map"
  type        = map(string)
  default     = {}
}