variable "name" {
  description = "ECS name"
  type        = string
}

variable "container_name" {
  description = "Name of containers created by ECS"
  type        = string
  default     = "the-plug-backend"
}

variable "ecr_repository_url" {
  description = "ECR repository URL that stores container image"
  type        = string
}

variable "image_tag" {
  description = "Container image tag"
  type        = string
  default     = "latest"
}

variable "container_port" {
  description = "Port exposed in container"
  type        = number
  default     = 0
}

variable "host_port" {
  description = "Host port bound to container"
  type        = number
  default     = 0
}

variable "db_endpoint" {
  description = "Database endpoint"
  type        = string
}

variable "db_name" {
  description = "Database name"
  type        = string
}

variable "db_user" {
  description = "Database user"
  type        = string
}

variable "cache_endpoint" { # TODO make backend use cache
  description = ""
  type        = string
  default     = ""
}

variable "db_password_secret_arn" {
  description = "Database password secret ARN"
  type        = string
}

variable "email_host_user_secret_arn" {
  description = "Email host user secret ARN"
  type        = string
}

variable "email_host_password_secret_arn" {
  description = "Email host password secret ARN"
  type        = string
}

variable "secret_key_secret_arn" {
  description = "Django backend secret key secret ARN"
  type        = string
}

variable "target_group_arn" {
  description = "ALB target group ARN"
  type        = string
}

variable "alarm_topic_arn" {
  description = "Alarm topic ARN"
  type        = string
}

variable "tags" {
  description = "Resource tag map"
  type        = map(string)
  default     = {}
}