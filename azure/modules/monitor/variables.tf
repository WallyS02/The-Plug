variable "resource_group_name" {
  description = "Resource Group name"
  type        = string
}

variable "location" {
  description = "Azure Region"
  type        = string
  default     = "polandcentral"
}

variable "workspace_name" {
  description = "Log Analytics Workspace name"
  type        = string
  default     = "the-plug-law"
}

variable "action_group_name" {
  description = "Action Group name"
  type        = string
  default     = "the-plug-ag"
}

variable "monitored_resources" {
  description = "Monitored resources list"
  type = list(object({
    name               = string
    target_resource_id = string
  }))
  default = []
}

variable "alert_rules" {
  description = "Alert rule list"
  type = list(object({
    name               = string
    target_resource_id = string
    metric_name        = string
    threshold          = number
    operator           = string # GreaterThan, LessThan
    aggregation        = string # Total, Average, Min, Max
    severity           = number
  }))
  default = []
}

variable "email" {
  description = "Email to send alerts to"
  type        = string
  sensitive   = true
}

variable "tags" {
  description = "Resource tag map"
  type        = map(string)
  default     = {}
}