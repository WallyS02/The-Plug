module "storage-account" {
  source              = "./modules/storage-account"
  resource_group_name = azurerm_resource_group.this.name

  tags = {
    Environment = "dev"
  }
}