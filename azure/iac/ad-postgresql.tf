module "ad-postgresql" {
  source                 = "./modules/ad-postgresql"
  resource_group_name    = azurerm_resource_group.this.name
  subnet_id              = module.vnet.private_subnet_id
  administrator_login    = "plug"
  administrator_password = azurerm_key_vault_secret.db-password.value

  tags = {
    Environment = "dev"
  }
}