variable "region" {
  description = "Default used region"
  type        = string
  default     = "eu-north-1"
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
  description = "Email for alarm SNS topic"
  type        = string
}