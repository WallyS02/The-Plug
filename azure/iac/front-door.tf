module "front-door" {
  source              = "./modules/front-door"
  resource_group_name = azurerm_resource_group.this.name
  zone_id             = module.dns.dns_zone_id
  zone_name           = module.dns.fqdn
  blob_host           = module.storage-account.static_endpoint
  aks_backend_host    = module.aks.aks_fqdn

  tags = {
    Environment = "dev"
  }
}