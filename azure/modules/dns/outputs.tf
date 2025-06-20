output "dns_zone_id" {
  description = "DNS Zone ID"
  value       = azurerm_dns_zone.this.id
}

output "fqdn" {
  description = "DNS Zone FQDN"
  value       = azurerm_dns_zone.this.name
}