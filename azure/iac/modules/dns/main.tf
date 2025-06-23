// DNS Zone
resource "azurerm_dns_zone" "this" {
  name                = var.zone_name
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

// DNS A alias record pointing to Application Gateway IP
resource "azurerm_dns_a_record" "this" {
  name                = var.record_name
  zone_name           = var.zone_name
  resource_group_name = var.resource_group_name
  ttl                 = 3600
  target_resource_id  = var.application_gateway_ip_id

  tags = var.tags
}