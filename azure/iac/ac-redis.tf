module "ac-redis" {
  source              = "./modules/ac-redis"
  resource_group_name = azurerm_resource_group.this.name

  tags = {
    Environment = "dev"
  }
}