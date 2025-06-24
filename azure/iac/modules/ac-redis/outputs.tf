output "redis_hostname" {
  description = "Redis instance hostname"
  value       = azurerm_redis_cache.this.hostname
}

output "redis_primary_access_key" {
  description = "Redis primary access key"
  value       = azurerm_redis_cache.this.primary_access_key
  sensitive   = true
}

output "redis_secondary_access_key" {
  description = "Redis secondary access key"
  value       = azurerm_redis_cache.this.secondary_access_key
  sensitive   = true
}

output "redis_id" {
  description = "Redis ID"
  value       = azurerm_redis_cache.this.id
}