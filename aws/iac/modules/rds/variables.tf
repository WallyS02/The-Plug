variable "identifier" {
  description = "Unique RDS instance identifier"
  type        = string
}

variable "engine" {
  description = "Database engine type"
  type        = string
  default     = "postgres"
}

variable "engine_version" {
  description = "Engine version"
  type        = string
  default     = "17.4"
}

variable "instance_class" {
  description = "RDS instance type"
  type        = string
  default     = "db.t3.micro"
}

variable "allocated_storage" {
  description = "Allocated storage (GiB)"
  type        = number
  default     = 20
}

variable "max_allocated_storage" {
  description = "Maximal allocated storage (GiB)"
  type        = number
  default     = 20
}

variable "storage_type" {
  description = "Storage disk type (gp2/gp3/io1)"
  type        = string
  default     = "gp3"
}

variable "db_name" {
  description = "Database name"
  type        = string
}

variable "username" {
  description = "Master username"
  type        = string
}

variable "password" {
  description = "Master user password"
  type        = string
  sensitive   = true
  default     = null
}

variable "port" {
  description = "Database port"
  type        = number
  default     = 5432
}

variable "subnet_ids" {
  description = "Subnet ID list"
  type        = list(string)
}

variable "multi_az" {
  description = "Enable Multi-AZ mode?"
  type        = bool
  default     = false
}

variable "backup_retention_period" {
  description = "Backup retention period (in days)"
  type        = number
  default     = 7
}

variable "backup_window" {
  description = "Backup window (e.g. 04:00-05:00)"
  type        = string
  default     = "02:00-03:00"
}

variable "maintenance_window" {
  description = "Maintenance window (e.g. Mon:03:00-Mon:04:00)"
  type        = string
  default     = "Sun:02:00-Sun:03:00"
}

variable "parameters" {
  description = "Database configuration parameters"
  type = list(object({
    name         = string
    value        = string
    apply_method = string
  }))
  default = []
}

variable "parameters_group_family" {
  description = "Parameters group family"
  type        = string
  default     = "postgres17"
}

variable "rds_security_group" {
  description = "RDS database security group"
  type        = list(string)
  default     = []
}

variable "kms_key_arn" {
  description = "KMS key ARN"
  type        = string
  default     = null
}

variable "deletion_protection" {
  description = "Enable deletion protection?"
  type        = bool
  default     = true
}

variable "performance_insights_enabled" {
  description = "Enable performance insights?"
  type        = bool
  default     = false
}

variable "performance_insights_retention_period" {
  description = "Performance insights retention period (in days)"
  type        = number
  default     = 7
}

variable "monitoring_interval" {
  description = "Monitoring interval (0|1|5|10|15|30|60)"
  type        = number
  default     = 0
}

variable "cloud_watch_log_exports" {
  description = "Log list to export to CloudWatch"
  type        = list(string)
  default     = ["error"]
}

variable "skip_final_snapshot" {
  description = "Skip final snapshot when deleting?"
  type        = bool
  default     = false
}

variable "final_snapshot_identifier" {
  description = "Final snapshot name"
  type        = string
  default     = null
}

variable "license_model" {
  description = "License model (e.g. license-included)"
  type        = string
  default     = null
}

variable "tags" {
  description = "Resource tag map"
  type        = map(string)
  default     = {}
}