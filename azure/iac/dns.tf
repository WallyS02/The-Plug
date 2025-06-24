module "dns" {
  source                    = "./modules/dns"
  resource_group_name       = azurerm_resource_group.this.name
  application_gateway_ip_id = module.application-gateway.application_gateway_public_ip_id

  tags = {
    Environment = "dev"
  }
}