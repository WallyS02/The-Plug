output "application_gateway_id" {
  description = "Application Gateway ID"
  value       = azurerm_application_gateway.this.id
}

output "application_gateway_public_ip" {
  description = "Application Gateway Public IP"
  value       = azurerm_public_ip.agw-pip.ip_address
}

output "application_gateway_public_ip_id" {
  description = "Application Gateway Public IP ID"
  value       = azurerm_public_ip.agw-pip.id
}

output "application_gateway_identity_id" {
  description = "Application Gateway Identity ID"
  value       = azurerm_user_assigned_identity.agw_identity.id
}