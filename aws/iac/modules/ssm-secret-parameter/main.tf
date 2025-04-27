# Secret parameter
resource "aws_ssm_parameter" "this" {
  name = var.name
  description = var.description
  type = "SecureString"
  value = var.initial_value
  key_id = null
  overwrite = true

  tags = var.tags
}