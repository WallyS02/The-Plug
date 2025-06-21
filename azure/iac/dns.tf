module "dns" {
  source                 = "./modules/dns"
  resource_group_name    = azurerm_resource_group.this.name
  application_gateway_id = module.application-gateway.application_gateway_id

  tags = {
    Environment = "dev"
  }
}