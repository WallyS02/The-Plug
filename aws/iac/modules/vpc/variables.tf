variable "vpc_cidr" {
  description = "IPv4 CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnets_cidrs" {
  description = "IPv4 CIDR block list for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnets_cidrs" {
  description = "CIDR block list for private subnets"
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24"]
}

variable "azs" {
  description = "Availability Zones list"
  type        = list(string)
  default     = ["eu-north-1a", "eu-north-1b"]
}

variable "enable_vpc_flow_logs" {
  description = "Enable VPC Flow Logs?"
  type        = bool
  default     = false
}

variable "log_bucket" {
  description = "S3 bucket for VPC Flow Logs (if enable_vpc_flow_logs = true)"
  type        = string
  default     = ""
}

variable "nat_instance_ingress_security_groups" {
  description = "Ingress security groups for NAT Instance ingress control"
  type        = list(string)
  default     = []
}

variable "region" {
  description = "Used region"
  type        = string
}

variable "tags" {
  description = "Resource tag map"
  type        = map(string)
  default     = {}
}