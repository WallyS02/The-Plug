output "vnet_id" {
  description = "VNet ID"
  value       = azurerm_virtual_network.this.id
}

output "public_subnet_id" {
  description = "Public subnet ID"
  value       = azurerm_subnet.public.id
}

output "private_subnet_id" {
  description = "Private subnet ID"
  value       = azurerm_subnet.private.id
}