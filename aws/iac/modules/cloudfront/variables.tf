variable "distribution_name" {
  description = "CloudFront distribution name"
  type        = string
}

variable "enabled" {
  description = "Create active distribution?"
  type        = bool
  default     = true
}

variable "aliases" {
  description = "Domain aliases list"
  type        = list(string)
  default     = []
}

variable "origins" {
  description = "Origin configuration map"
  type = map(object({
    domain_name = string
    type        = string
    origin_path = optional(string)
  }))
}

variable "default_cache_behaviour" {
  description = "Default cache behaviour configuration"
  type = object({
    target_origin_id         = string
    allowed_methods          = list(string)
    cached_methods           = list(string)
    cache_policy_id          = string
    origin_request_policy_id = string
  })
}

variable "acm_certificate_arn" {
  description = "ACM SSL certificate ARN"
  type        = string
}

variable "create_origin_access_identity" {
  description = "Create OAI for S3?"
  type        = bool
  default     = true
}

variable "s3_bucket_id" {
  description = "S3 bucket ID (if create_origin_access_identity = true)"
  type        = string
  default     = ""
}

variable "s3_bucket_arn" {
  description = "S3 bucket ARN (if create_origin_access_identity = true)"
  type        = string
  default     = ""
}

variable "logging_enabled" {
  description = "Enable logging?"
  type        = bool
  default     = false
}

variable "logging_bucket" {
  description = "S3 bucket for logging (if logging_enabled = true)"
  type        = string
  default     = ""
}

variable "logging_prefix" {
  description = "Logging prefix (if logging_enabled = true)"
  type        = string
  default     = ""
}

variable "lambda_function_associations" {
  description = "Lambda@Edge configuration"
  type = list(object({
    event_type   = string
    lambda_arn   = string
    include_body = bool
  }))
  default = []
}

variable "geographical_restrictions" {
  description = "Geographical restrictions configuration"
  type = object({
    restriction_type = string
    locations        = list(string)
  })
  default = {
    restriction_type = "none"
    locations        = []
  }
}

variable "price_class" {
  description = "Price class"
  type        = string
  default     = "PriceClass_100"
}

variable "comment" {
  description = "Distribution comment"
  type        = string
}

variable "default_root_object" {
  description = "Default root object"
  type        = string
  default     = "index.html"
}

variable "tags" {
  description = "Resource tag map"
  type        = map(string)
  default     = {}
}