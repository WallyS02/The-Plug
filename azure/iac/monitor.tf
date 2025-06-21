module "monitor" {
  source              = "./modules/monitor"
  resource_group_name = azurerm_resource_group.this.name
  email               = var.email

  monitored_resources = [
    {
      name               = "ac-redis"
      target_resource_id = module.ac-redis.redis_id
    },
    {
      name               = "ad-postgresql"
      target_resource_id = module.ad-postgresql.postgres_server_id
    },
    /*{
      name               = "front-door"
      target_resource_id = module.front-door.frontdoor_id
    },*/
    {
      name               = "aks"
      target_resource_id = module.aks.aks_cluster_id
    },
    {
      name               = "key-vault"
      target_resource_id = module.key-vault.keyvault_id
    }
  ]

  alert_rules = [
    {
      name               = "cpu-high"
      target_resource_id = module.aks.aks_cluster_id
      metric_namespace   = "Microsoft.ContainerService/managedClusters"
      metric_name        = "Percentage CPU"
      threshold          = 80
      operator           = "GreaterThan"
      aggregation        = "Average"
      severity           = 2
    },
    {
      name               = "redis-memory-usage"
      target_resource_id = module.ac-redis.redis_id
      metric_namespace   = "Microsoft.Cache/redis"
      metric_name        = "used_memory_percentage"
      threshold          = 75
      operator           = "GreaterThan"
      aggregation        = "Average"
      severity           = 3
    },
    {
      name               = "postgres-storage-usage"
      target_resource_id = module.ad-postgresql.postgres_server_id
      metric_namespace   = "Microsoft.DBforPostgreSQL/flexibleServers"
      metric_name        = "storage_percent"
      threshold          = 90
      operator           = "GreaterThan"
      aggregation        = "Average"
      severity           = 2
    },
    /*{
      name               = "frontdoor-http5xx-errors"
      target_resource_id = module.front-door.frontdoor_id
      metric_namespace   = "Microsoft.Network/frontdoors"
      metric_name        = "Http5xx"
      threshold          = 10
      operator           = "GreaterThan"
      aggregation        = "Total"
      severity           = 3
    },*/
    {
      name               = "keyvault-throttled-requests"
      target_resource_id = module.key-vault.keyvault_id
      metric_namespace   = "Microsoft.KeyVault/vaults"
      metric_name        = "ClientThrottledRequests"
      threshold          = 10
      operator           = "GreaterThan"
      aggregation        = "Total"
      severity           = 3
    }
  ]

  tags = {
    Environment = "dev"
  }
}