variable "email" {
  description = "Email to send to alarm messages"
  type        = string
  sensitive   = true
  default     = "<mail>@gmail.com" # TODO email setup
}