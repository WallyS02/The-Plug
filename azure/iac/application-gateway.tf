module "application-gateway" {
  source                          = "./modules/application-gateway"
  resource_group_name             = azurerm_resource_group.this.name
  blob_host                       = split("/", module.storage-account.static_endpoint)[2]
  subnet_id                       = module.vnet.public_subnet_id
  key_vault_id                    = module.key-vault.keyvault_id
  key_vault_certificate_secret_id = azurerm_key_vault_certificate.this.secret_id

  tags = {
    Environment = "dev"
  }
}