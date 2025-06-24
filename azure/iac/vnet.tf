module "vnet" {
  source              = "./modules/vnet"
  resource_group_name = azurerm_resource_group.this.name
  redis_id            = module.ac-redis.redis_id
  postgres_id         = module.ad-postgresql.postgres_server_id

  tags = {
    Environment = "dev"
  }
}