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