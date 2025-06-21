module "application-gateway" {
  source                          = "./modules/application-gateway"
  resource_group_name             = azurerm_resource_group.this.name
  blob_host                       = module.storage-account.static_endpoint
  aks_backend_host                = module.aks.aks_fqdn
  subnet_id                       = module.vnet.public_subnet_a_id
  key_vault_certificate_secret_id = azurerm_key_vault_certificate.this.id

  tags = {
    Environment = "dev"
  }
}