// Public IP address for Application Gateway
resource "azurerm_public_ip" "agw-pip" {
  name                = "${var.name}-pip"
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = var.tags
}

// Application Gateway
resource "azurerm_application_gateway" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location

  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 2
  }

  gateway_ip_configuration {
    name      = "${var.name}-ipcfg"
    subnet_id = var.subnet_id
  }

  frontend_port {
    name = "port-http"
    port = 80
  }

  frontend_port {
    name = "port-https"
    port = 443
  }

  frontend_ip_configuration {
    name                 = "${var.name}-frontend-ip"
    public_ip_address_id = azurerm_public_ip.agw-pip.id
  }

  ssl_certificate {
    name                = "tls-cert"
    key_vault_secret_id = var.key_vault_certificate_secret_id
  }

  http_listener {
    name                           = "listener-https"
    frontend_ip_configuration_name = "${var.name}-frontend-ip"
    frontend_port_name             = "port-https"
    protocol                       = "Https"
    ssl_certificate_name           = "tls-cert"
    host_names                     = [var.custom_domain]
  }

  http_listener {
    name                           = "listener-http"
    frontend_ip_configuration_name = "${var.name}-frontend-ip"
    frontend_port_name             = "port-http"
    protocol                       = "Http"
    host_names                     = [var.custom_domain]
  }

  # Backend pools
  backend_address_pool {
    name  = "pool-blob"
    fqdns = [var.blob_host]
  }

  # HTTP settings
  backend_http_settings {
    name                                = "setting-blob"
    cookie_based_affinity               = "Disabled"
    port                                = 443
    protocol                            = "Https"
    request_timeout                     = var.request_timeout
    pick_host_name_from_backend_address = true
  }

  # Path‑based routing
  url_path_map {
    name                               = "url-path-map"
    default_backend_address_pool_name  = "pool-blob"
    default_backend_http_settings_name = "setting-blob"

    path_rule {
      name                       = "frontend-rule"
      paths                      = ["/*"]
      backend_address_pool_name  = "pool-blob"
      backend_http_settings_name = "setting-blob"
    }
  }

  # Redirect HTTP → HTTPS
  redirect_configuration {
    name                 = "redirect-http-to-https"
    redirect_type        = "Permanent"
    target_listener_name = "listener-https"
    include_path         = true
    include_query_string = true
  }

  request_routing_rule {
    name                        = "rule-http-redirect"
    rule_type                   = "Basic"
    http_listener_name          = "listener-http"
    redirect_configuration_name = "redirect-http-to-https"
    priority                    = 1
  }

  # Main HTTPS routing
  request_routing_rule {
    name               = "rule-https"
    rule_type          = "PathBasedRouting"
    http_listener_name = "listener-https"
    url_path_map_name  = "url-path-map"
    priority           = 2
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.agw_identity.id]
  }

  tags = var.tags

  depends_on = [azurerm_key_vault_access_policy.appgw_policy]
}

data "azurerm_client_config" "current" {}

resource "azurerm_user_assigned_identity" "agw_identity" {
  name                = "${var.name}-identity"
  resource_group_name = var.resource_group_name
  location            = var.location
}

resource "azurerm_key_vault_access_policy" "appgw_policy" {
  key_vault_id = var.key_vault_id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_user_assigned_identity.agw_identity.principal_id

  certificate_permissions = ["Get", "List"]
  secret_permissions      = ["Get", "List"]
}