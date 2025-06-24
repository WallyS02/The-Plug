module "aks" {
  source              = "./modules/aks"
  resource_group_name = azurerm_resource_group.this.name
  resource_group_id   = azurerm_resource_group.this.id
  vnet_subnet_id      = module.vnet.private_subnet_id
  acr_id              = module.acr.acr_id
  agic_id             = module.agic.agic_id
  agic_identity_id    = module.agic.agic_identity_id
  agic_subnet_id      = module.vnet.public_subnet_id
  key_vault_id        = module.key-vault.keyvault_id

  tags = {
    Environment = "dev"
  }
}