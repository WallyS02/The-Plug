// DNS Zone
resource "azurerm_dns_zone" "this" {
  name                = var.zone_name
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

// DNS CNAME alias record pointing to Application Gateway
resource "azurerm_dns_cname_record" "this" {
  name                = var.zone_name
  zone_name           = var.zone_name
  resource_group_name = var.resource_group_name
  ttl                 = 3600
  target_resource_id  = var.application_gateway_id

  tags = var.tags
}