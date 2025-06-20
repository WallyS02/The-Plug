variable "region" {
  description = "Default used region"
  type        = string
  default     = "polandcentral"
}

variable "resource_group" {
  description = "Default resource group name"
  type        = string
  default     = "the-plug"
}

variable "subscription_id" {
  type        = string
  description = "Azure Subscription ID"
}

variable "tenant_id" {
  type        = string
  description = "Azure Tenant (Entra ID) ID"
}

variable "email_host_user_secret" {
  description = "Email host user secret value"
  type        = string
}

variable "email_host_password_secret" {
  description = "Email host password secret value"
  type        = string
}

variable "secret_key_secret" {
  description = "Django secret key secret value"
  type        = string
}

variable "email" {
  description = "Email for alarms"
  type        = string
}