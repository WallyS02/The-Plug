variable "domain_name" {
  description = "Main domain for certificate"
  type        = string
}

variable "subject_alternative_names" {
  description = "Subject Alternative domain Names (SANs)"
  type        = list(string)
  default     = []
}

variable "validation_method" {
  description = "Validation method (DNS/EMAIL)"
  type        = string
  default     = "DNS"
}

variable "hosted_zone_id" {
  description = "Hosted Zone ID in Route 53 for DNS validation"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Resource tag map"
  type        = map(string)
  default     = {}
}