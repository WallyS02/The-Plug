output "postgres_fqdn" {
  description = "PostgreSQL server FQDN"
  value       = azurerm_postgresql_server.this.fqdn
}

output "postgres_server_id" {
  description = "PostgreSQL server ID"
  value       = azurerm_postgresql_server.this.id
}