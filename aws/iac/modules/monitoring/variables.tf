variable "alarms" {
  description = "CloudWatch alarms configuration map"
  type = map(object({
    metric_name         = string
    namespace           = string
    statistic           = string
    period              = number
    evaluation_periods  = number
    comparison_operator = string
    threshold           = number
    description         = string
    alarm_actions       = list(string)
    ok_actions          = list(string)
    dimensions          = map(string)
  }))
  default = {}
}

variable "dashboard_name" {
  description = "CloudWatch dashboard name"
  type        = string
  default     = null
}

variable "dashboard_config" {
  description = "CloudWatch dashboard configuration in JSON format"
  type        = any
  default     = null
}

variable "log_groups" {
  description = "Log groups configuration map"
  type = map(object({
    retention_in_days = number
    kms_key_arn       = string
  }))
  default = {}
}

variable "metric_filters" {
  description = "CloudWatch metric filters map"
  type = map(object({
    pattern          = string
    log_group_name   = string
    metric_name      = string
    metric_namespace = string
    metric_value     = string
  }))
  default = {}
}

variable "create_iam_role" {
  description = "Create IAM role for CloudWatch Agent?"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Resource tag map"
  type        = map(string)
  default     = {}
}