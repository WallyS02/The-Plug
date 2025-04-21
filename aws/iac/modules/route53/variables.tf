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

variable "tags" {
  description = "Resource tag map"
  type        = map(string)
  default     = {}
}