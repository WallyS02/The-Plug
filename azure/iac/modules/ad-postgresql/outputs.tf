output "postgres_fqdn" {
  description = "PostgreSQL flexible server FQDN"
  value       = azurerm_postgresql_flexible_server.this.fqdn
}

output "postgres_server_id" {
  description = "PostgreSQL flexible server ID"
  value       = azurerm_postgresql_flexible_server.this.id
}