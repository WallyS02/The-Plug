variable "name" {
  description = "Redis cluster name"
  type        = string
}

variable "subnet_ids" {
  description = "Subnets ID list"
  type        = list(string)
}

variable "node_type" {
  description = "Redis instance type"
  type        = string
  default     = "cache.t3.micro"
}

variable "redis_version" {
  description = "Redis version"
  type        = string
  default     = "7.1"
}

variable "redis_family" {
  description = "Redis parameter family"
  type        = string
  default     = "redis7"
}

variable "port" {
  description = "Redis port"
  type        = number
  default     = 6379
}

variable "encryption_at_rest" {
  description = "Encrypting data at rest"
  type        = bool
  default     = true
}

variable "encryption_in_transit" {
  description = "Encrypting data in transit"
  type        = bool
  default     = true
}

variable "auth_token" {
  description = "Authorization Redis token"
  type        = string
  sensitive   = true
  default     = null
}

variable "maintenance_window" {
  description = "Maintenance window (e.g. mon:03:00-mon:04:00)"
  type        = string
  default     = "sun:02:00-sun:03:00"
}

variable "redis_security_group" {
  description = "Redis security group"
  type        = list(string)
  default     = []
}

variable "redis_parameters" {
  description = "Redis parameter list"
  type = list(object({
    name  = string
    value = string
  }))
  default = []
}

variable "alarm_topic_arn" {
  description = "Alarm topic ARN"
  type        = string
}

variable "high_evictions_threshold" {
  description = "High number of cache evictions threshold"
  type        = number
  default     = 100
}

variable "tags" {
  description = "Resource tag map"
  type        = map(string)
  default     = {}
}