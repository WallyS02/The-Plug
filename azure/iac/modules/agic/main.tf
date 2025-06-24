// Public IP address for AGIC
resource "azurerm_public_ip" "agic-pip" {
  name                = "${var.name}-pip"
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = var.tags
}

// AGIC
resource "azurerm_application_gateway" "agic" {
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
    public_ip_address_id = azurerm_public_ip.agic-pip.id
  }

  http_listener {
    name                           = "listener"
    frontend_ip_configuration_name = "${var.name}-frontend-ip"
    frontend_port_name             = "port-http"
    protocol                       = "Http"
  }

  backend_address_pool {
    name = "pool"
  }

  backend_http_settings {
    name                  = "setting"
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
  }

  request_routing_rule {
    name                       = "rule"
    rule_type                  = "Basic"
    http_listener_name         = "listener"
    backend_address_pool_name  = "pool"
    backend_http_settings_name = "setting"
    priority                   = 1
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.agic_identity.id]
  }

  tags = var.tags

  lifecycle {
    ignore_changes = [backend_address_pool, backend_http_settings, http_listener, probe, request_routing_rule, url_path_map, frontend_port, tags]
  }
}

data "azurerm_client_config" "current" {}

resource "azurerm_user_assigned_identity" "agic_identity" {
  name                = "${var.name}-identity"
  resource_group_name = var.resource_group_name
  location            = var.location
}