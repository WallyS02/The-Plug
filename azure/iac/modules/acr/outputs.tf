output "acr_login_server" {
  description = "ACR login server"
  value       = azurerm_container_registry.this.login_server
}

output "acr_name" {
  description = "ACR name"
  value       = azurerm_container_registry.this.name
}

output "acr_id" {
  description = "ACR ID"
  value       = azurerm_container_registry.this.id
}