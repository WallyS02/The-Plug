output "frontdoor_id" {
  description = "Front Door ID"
  value       = azurerm_frontdoor.this.id
}

output "frontdoor_host_name" {
  description = "Front Door hostname"
  value       = azurerm_frontdoor.this.frontend_endpoint[0].host_name
}