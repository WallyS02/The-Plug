module "aks" {
  source              = "./modules/aks"
  resource_group_name = azurerm_resource_group.this.name
  vnet_subnet_id      = module.vnet.public_subnet_a_id
  acr_id              = module.acr.acr_id
  gateway_id          = module.application-gateway.application_gateway_id
  key_vault_id        = module.key-vault.keyvault_id

  tags = {
    Environment = "dev"
  }
}