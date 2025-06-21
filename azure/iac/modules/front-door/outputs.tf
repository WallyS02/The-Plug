output "frontdoor_id" {
  description = "Front Door ID"
  value       = azurerm_cdn_frontdoor_endpoint.this.id
}

output "frontdoor_host_name" {
  description = "Front Door hostname"
  value       = azurerm_cdn_frontdoor_endpoint.this.host_name
}