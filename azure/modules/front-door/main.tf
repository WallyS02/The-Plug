// Front Door Profile
resource "azurerm_cdn_frontdoor_profile" "this" {
  name                = "${var.name}-profile"
  resource_group_name = var.resource_group_name
  sku_name            = "Standard_AzureFrontDoor"
  tags                = var.tags
}

// Front Door Endpoint
resource "azurerm_cdn_frontdoor_endpoint" "this" {
  name                     = "${var.name}-endpoint"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.this.id
  tags                     = var.tags
}

// Front Door Custom Domain
resource "azurerm_cdn_frontdoor_custom_domain" "this" {
  name                     = "${var.name}-custom-domain"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.this.id
  dns_zone_id              = var.zone_id
  host_name                = var.custom_domain

  tls {
    certificate_type = "ManagedCertificate"
  }
}

// Azure DNS TXT record to authenticate Front Door
resource "azurerm_dns_txt_record" "this" {
  name                = join(".", ["_dnsauth", split(".", var.custom_domain)[0]])
  zone_name           = var.zone_name
  resource_group_name = var.resource_group_name
  ttl                 = 3600

  record {
    value = azurerm_cdn_frontdoor_custom_domain.this.validation_token
  }
}

// Static Frontend Front Door Origin and Origin Group
resource "azurerm_cdn_frontdoor_origin_group" "static_group" {
  name                     = "${var.name}-og-static"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.this.id

  load_balancing {
    sample_size                 = 4
    successful_samples_required = 3
  }

  health_probe {
    protocol            = "Https"
    path                = "/"
    request_type        = "HEAD"
    interval_in_seconds = var.frontend_healthcheck_interval
  }
}

resource "azurerm_cdn_frontdoor_origin" "static_origin" {
  name                           = "${var.name}-static-origin"
  cdn_frontdoor_origin_group_id  = azurerm_cdn_frontdoor_origin_group.static_group.id
  host_name                      = var.blob_host
  http_port                      = var.frontend_port
  https_port                     = var.frontend_port
  origin_host_header             = var.blob_host
  certificate_name_check_enabled = false
}

// API Front Door Origin and Origin Group
resource "azurerm_cdn_frontdoor_origin_group" "api_group" {
  name                     = "${var.name}-og-api"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.this.id

  load_balancing {
    sample_size                 = 4
    successful_samples_required = 3
  }

  health_probe {
    protocol            = "Https"
    path                = var.api_healthcheck_endpoint
    request_type        = "GET"
    interval_in_seconds = var.api_healthcheck_interval
  }
}

resource "azurerm_cdn_frontdoor_origin" "api_origin" {
  name                           = "${var.name}-api-origin"
  cdn_frontdoor_origin_group_id  = azurerm_cdn_frontdoor_origin_group.api_group.id
  host_name                      = var.aks_backend_host
  http_port                      = var.api_port
  https_port                     = var.api_port
  origin_host_header             = var.aks_backend_host
  certificate_name_check_enabled = false
}

// Front Door Routes
resource "azurerm_cdn_frontdoor_route" "root" {
  name                          = "${var.name}-route-static"
  cdn_frontdoor_endpoint_id     = azurerm_cdn_frontdoor_endpoint.this.id
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.static_group.id
  cdn_frontdoor_origin_ids      = [azurerm_cdn_frontdoor_origin.static_origin.id]

  patterns_to_match      = ["/*"]
  supported_protocols    = ["Https", "Http"]
  forwarding_protocol    = "HttpsOnly"
  https_redirect_enabled = true
  link_to_default_domain = false

  cache {
    compression_enabled = true
    content_types_to_compress = [
      "text/html",
      "application/json",
      "application/javascript",
      "text/css",
      "application/xml",
      "text/xml"
    ]
  }
}

resource "azurerm_cdn_frontdoor_route" "api" {
  name                          = "${var.name}-route-api"
  cdn_frontdoor_endpoint_id     = azurerm_cdn_frontdoor_endpoint.this.id
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.api_group.id
  cdn_frontdoor_origin_ids      = [azurerm_cdn_frontdoor_origin.api_origin.id]

  patterns_to_match      = ["/api/*"]
  supported_protocols    = ["Https", "Http"]
  forwarding_protocol    = "HttpsOnly"
  https_redirect_enabled = true
  link_to_default_domain = false
}