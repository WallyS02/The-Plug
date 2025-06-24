output "agic_id" {
  description = "AGIC ID"
  value       = azurerm_application_gateway.agic.id
}

output "agic_public_ip" {
  description = "AGIC Public IP"
  value       = azurerm_public_ip.agic-pip.ip_address
}

output "agic_public_ip_id" {
  description = "AGIC Public IP ID"
  value       = azurerm_public_ip.agic-pip.id
}

output "agic_identity_id" {
  description = "AGIC Identity ID"
  value       = azurerm_user_assigned_identity.agic_identity.id
}