variable "name_prefix" {
  description = "Resource name prefix"
  type        = string
}

variable "ami_id" {
  description = "AMI ID"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "SSH key name"
  type        = string
  default     = null
}

variable "security_group_ids" {
  description = "Security groups ID list"
  type        = list(string)
}

variable "vpc_zone_identifier" {
  description = "Subnet ID list"
  type        = list(string)
}

variable "desired_capacity" {
  description = "Initial number of instances"
  type        = number
  default     = 1
}

variable "min_size" {
  description = "Minimal number of instances"
  type        = number
  default     = 1
}

variable "max_size" {
  description = "Maximal number of instances"
  type        = number
  default     = 2
}

variable "health_check_type" {
  description = "Health check type (EC2/ELB)"
  type        = string
  default     = "EC2"
}

variable "health_check_grace_period" {
  description = "Health check grace period in seconds"
  type        = number
  default     = 300
}

variable "user_data_base64" {
  description = "User data in base64 format"
  type        = string
  default     = null
}

variable "enable_monitoring" {
  description = "Enable detailed monitoring?"
  type        = bool
  default     = true
}

variable "block_device_mappings" {
  description = "EBS disks configuration"
  type = list(object({
    device_name           = string
    volume_size           = number
    volume_type           = string
    delete_on_termination = bool
    encrypted             = bool
  }))
  default = [{
    device_name           = "/dev/xvda"
    volume_size           = 8
    volume_type           = "gp3"
    delete_on_termination = true
    encrypted             = true
  }]
}

variable "enable_scaling_policies" {
  description = "Enable scaling policies?"
  type        = bool
  default     = false
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

variable "wait_for_capacity_timeout" {
  description = "Timeout for instance initialization"
  type        = string
  default     = "10m"
}

variable "cw_agent_ssm_parameter_name" {
  description = "Name for CW Agent SSM parameter"
  type        = string
  default     = "/cloudwatch-agent/config"
}

variable "tags" {
  description = "Resource tag map"
  type        = map(string)
  default     = {}
}