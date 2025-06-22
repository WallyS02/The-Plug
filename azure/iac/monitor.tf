module "monitor" {
  source              = "./modules/monitor"
  resource_group_name = azurerm_resource_group.this.name
  email               = var.email

  monitored_resources = [
    {
      name               = "ad-postgresql"
      target_resource_id = module.ad-postgresql.postgres_server_id
      log_categories     = ["PostgreSQLLogs"]
    },
    {
      name               = "aks"
      target_resource_id = module.aks.aks_cluster_id
      log_categories     = ["kube-apiserver", "kube-controller-manager", "kube-scheduler"]
    }
  ]

  alert_rules = [
    {
      name               = "cpu-high"
      target_resource_id = module.aks.aks_cluster_id
      metric_namespace   = "microsoft.kubernetes/connectedClusters"
      metric_name        = "node_cpu_usage_percentage"
      threshold          = 90
      operator           = "GreaterThan"
      aggregation        = "Average"
      severity           = 2
    },
    {
      name               = "redis-memory-usage"
      target_resource_id = module.ac-redis.redis_id
      metric_namespace   = "Microsoft.Cache/redis"
      metric_name        = "allusedmemorypercentage"
      threshold          = 80
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
    {
      name               = "application-gateway-errors"
      target_resource_id = module.application-gateway.application_gateway_id
      metric_namespace   = "Microsoft.Network/applicationgateways"
      metric_name        = "FailedRequests"
      threshold          = 10
      operator           = "GreaterThan"
      aggregation        = "Total"
      severity           = 3
    },
    {
      name               = "keyvault-availability"
      target_resource_id = module.key-vault.keyvault_id
      metric_namespace   = "Microsoft.KeyVault/vaults"
      metric_name        = "Availability"
      threshold          = 75
      operator           = "LessThan"
      aggregation        = "Average"
      severity           = 3
    }
  ]

  tags = {
    Environment = "dev"
  }
}