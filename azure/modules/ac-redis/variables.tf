variable "resource_group_name" {
  description = "Resource Group name"
  type        = string
}

variable "location" {
  description = "Azure Region"
  type        = string
  default     = "polandcentral"
}

variable "redis_name" {
  description = "Redis name"
  type        = string
  default = "the-plug"
}

variable "capacity" {
  description = "Redis instance capacity (number of shards or size in GB)"
  type        = number
  default     = 1
}

variable "tags" {
  description = "Resource tag map"
  type        = map(string)
  default     = {}
}