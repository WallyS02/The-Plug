output "storage_account_name" {
  description = "Storage Account name"
  value       = azurerm_storage_account.this.name
}

output "static_endpoint" {
  description = "Storage Account static site URL"
  value       = azurerm_storage_account.this.primary_web_endpoint
}

output "storage_account_id" {
  description = "Storage Account ID"
  value       = azurerm_storage_account.this.id
}