variable "domain_name" {
  description = "Main domain name"
  type        = string
}

variable "create_hosted_zone" {
  description = "Create hosted zone?"
  type        = bool
  default     = true
}

variable "existing_zone_id" {
  description = "Existing hosting zone ID (if create_hosted_zone = false)"
  type        = string
  default     = ""
}

variable "private_zone" {
  description = "Create private zone?"
  type        = bool
  default     = false
}

variable "vpc_ids" {
  description = "VPC ID list for private zone"
  type        = list(string)
  default     = []
}

variable "records" {
  description = "DNS record list"
  type = list(object({
    name    = string
    type    = string
    ttl     = optional(number)
    records = optional(list(string))
    alias = optional(object({
      name                   = string
      zone_id                = string
      evaluate_target_health = optional(bool)
    }))
  }))
  default = []
}

variable "enable_dnssec" {
  description = "Enable DNSSEC for the hosted zone?"
  type = bool
  default = false
}

variable "key_management_service_arn" {
  description = "Key for DNSSEC ARN (if enable_dnssec = true)"
  type = string
  default = ""
}

variable "tags" {
  description = "Resource tag map"
  type        = map(string)
  default     = {}
}