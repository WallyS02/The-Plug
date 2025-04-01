variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnets_cidrs" {
  description = "CIDR block list for public subnets"
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

variable "enable_nat_gateway" {
  description = "Create NAT Gateway?"
  type        = bool
  default     = false
}

variable "enable_s3_endpoint" {
  description = "Create S3 VPC Endpoint?"
  type        = bool
  default     = true
}

variable "region" {
  description = "AWS Region"
  type        = string
  default     = "eu-north-1"
}

variable "tags" {
  description = "Resource tag map"
  type        = map(string)
  default     = {}
}