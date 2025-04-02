variable "name" {
  description = "ALB name"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "vpc_id" {
  description = "ID VPC"
  type        = string
}

variable "security_groups" {
  description = "Security groups list"
  type        = list(string)
}

variable "subnet_ids" {
  description = "Subnets ID list"
  type        = list(string)
}

variable "internal" {
  description = "Create internal ALB?"
  type        = bool
  default     = false
}

variable "target_port" {
  description = "EC2 instances target port"
  type        = number
  default     = 80
}

variable "health_check_path" {
  description = "Health check path"
  type        = string
  default     = "/health"
}

variable "enable_http" {
  description = "Enable HTTP listener?"
  type        = bool
  default     = true
}

variable "enable_https" {
  description = "Enable HTTPS listener?"
  type        = bool
  default     = true
}

variable "acm_certificate_arn" {
  description = "ACM SSL certificate ARN"
  type        = string
  default     = ""
}

variable "enable_deletion_protection" {
  description = "Enable deletion protection?"
  type        = bool
  default     = true
}

variable "enable_access_logs" {
  description = "Enable access logging?"
  type        = bool
  default     = false
}

variable "logging_bucket" {
  description = "S3 bucket for logging (if enable_access_logs = true)"
  type        = string
  default     = ""
}

variable "logging_prefix" {
  description = "Logging prefix (if enable_access_logs = true)"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Resource tag map"
  type        = map(string)
  default     = {}
}