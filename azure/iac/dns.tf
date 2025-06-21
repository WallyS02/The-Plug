module "dns" {
  source              = "./modules/dns"
  resource_group_name = azurerm_resource_group.this.name

  tags = {
    Environment = "dev"
  }
}