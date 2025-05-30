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
  default     = 8080
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

variable "cache_endpoint" {
  description = "Redis cache endpoint"
  type        = string
}

variable "db_password_secret_arn" {
  description = "Database password secret ARN"
  type        = string
}

variable "cache_password_secret_arn" {
  description = "Cache password secret ARN"
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

variable "log_group" {
  description = "Log group for ECS"
  type        = string
}

variable "log_region" {
  description = "Region for log group for ECS"
  type        = string
}

variable "container_memory" {
  description = "Amount (in MiB) of memory used by the single task container"
  type        = number
  default     = 512 # 512 MB
}

variable "desired_count" {
  description = "Number of instances of the task definition to place and keep running"
  type        = number
  default     = 1
}

variable "enable_container_insights" {
  description = "Enable container insights?"
  type        = bool
  default     = false
}

variable "asg_arn" {
  description = "ASG ARN"
  type        = string
}

variable "cpu_utilization_threshold" {
  description = "CPU utilization threshold"
  type        = number
  default     = 70
}

variable "memory_utilization_threshold" {
  description = "Memory utilization threshold"
  type        = number
  default     = 70
}

variable "minimum_capacity" {
  description = "Minimum number of running containers"
  type        = number
  default     = 1
}

variable "maximum_capacity" {
  description = "Maximum number of running containers"
  type        = number
  default     = 2
}

variable "scaling_cooldown" {
  description = "Time in seconds between scaling actions"
  type        = number
  default     = 300
}

variable "tags" {
  description = "Resource tag map"
  type        = map(string)
  default     = {}
}