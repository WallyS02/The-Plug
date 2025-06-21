output "application_gateway_id" {
  description = "Application Gateway ID"
  value       = azurerm_application_gateway.this.id
}

output "application_gateway_public_ip" {
  description = "Application Gateway Public IP"
  value       = azurerm_public_ip.agw-pip.ip_address
}