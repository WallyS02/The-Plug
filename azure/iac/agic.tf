module "agic" {
  source              = "./modules/agic"
  resource_group_name = azurerm_resource_group.this.name
  subnet_id           = module.vnet.public_subnet_id
}