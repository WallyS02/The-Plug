module "acr" {
  source              = "./modules/acr"
  resource_group_name = azurerm_resource_group.this.name

  tags = {
    Environment = "dev"
  }
}