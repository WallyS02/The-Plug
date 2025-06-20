output "vnet_id" {
  description = "VNet ID"
  value       = azurerm_virtual_network.this.id
}

output "public_subnet_a_id" {
  description = "Public subnet A ID"
  value       = azurerm_subnet.public_a.id
}

output "public_subnet_b_id" {
  description = "Public subnet B ID"
  value       = azurerm_subnet.public_b.id
}

output "private_subnet_id" {
  description = "Private subnet ID"
  value       = azurerm_subnet.private.id
}

output "nat_gateway_id" {
  description = "NAT Gateway ID"
  value       = azurerm_nat_gateway.this.id
}

output "public_ip_nat" {
  description = "NAT Gateway Public IP"
  value       = azurerm_public_ip.this.ip_address
}