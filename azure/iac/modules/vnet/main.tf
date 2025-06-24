// VNet and Subnets
resource "azurerm_virtual_network" "this" {
  name                = "${var.vnet_name}-vnet"
  resource_group_name = var.resource_group_name
  location            = var.location
  address_space       = var.address_space
  tags                = var.tags
}

resource "azurerm_subnet" "public" {
  name                 = "${var.vnet_name}-public-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = [var.public_subnet_prefix]
}

resource "azurerm_subnet" "private" {
  name                 = "${var.vnet_name}-private-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = [var.private_subnet_prefix]
}

// Private Endpoints (Redis, PostgreSQL) for private subnet
resource "azurerm_private_endpoint" "redis_pe" {
  name                = "${var.vnet_name}-ps-pe-redis"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = azurerm_subnet.private.id

  private_service_connection {
    name                           = "psconn-redis"
    private_connection_resource_id = var.redis_id
    subresource_names              = ["redisCache"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "${var.vnet_name}-redis-dns-zone-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.redis_zone.id]
  }
}

resource "azurerm_private_dns_zone" "redis_zone" {
  name                = var.redis_private_link_hostname
  resource_group_name = var.resource_group_name
}

resource "azurerm_private_dns_zone_virtual_network_link" "redis_link" {
  name                  = "${var.vnet_name}-redis-link"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.redis_zone.name
  virtual_network_id    = azurerm_virtual_network.this.id
}

resource "azurerm_private_dns_a_record" "redis_record" {
  name                = var.service_name
  zone_name           = azurerm_private_dns_zone.redis_zone.name
  resource_group_name = var.resource_group_name
  ttl                 = 300
  records             = [azurerm_private_endpoint.redis_pe.private_service_connection[0].private_ip_address]
}

resource "azurerm_private_endpoint" "postgres_pe" {
  name                = "${var.vnet_name}-ps-pe-postgres"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = azurerm_subnet.private.id

  private_service_connection {
    name                           = "psconn-postgres"
    private_connection_resource_id = var.postgres_id
    subresource_names              = ["postgresqlServer"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "${var.vnet_name}-postgres-dns-zone-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.postgres_zone.id]
  }
}

resource "azurerm_private_dns_zone" "postgres_zone" {
  name                = var.postgres_private_link_hostname
  resource_group_name = var.resource_group_name
}

resource "azurerm_private_dns_zone_virtual_network_link" "postgres_link" {
  name                  = "${var.vnet_name}-postgres-link"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.postgres_zone.name
  virtual_network_id    = azurerm_virtual_network.this.id
}

resource "azurerm_private_dns_a_record" "pg_record" {
  name                = var.service_name
  zone_name           = azurerm_private_dns_zone.postgres_zone.name
  resource_group_name = var.resource_group_name
  ttl                 = 300
  records             = [azurerm_private_endpoint.postgres_pe.private_service_connection[0].private_ip_address]
}

// NSG for public subnet
resource "azurerm_network_security_group" "this" {
  name                = "${var.vnet_name}-nsg-public"
  location            = var.location
  resource_group_name = var.resource_group_name

  security_rule {
    name                       = "Allow-HTTP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Allow-HTTPS"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Allow-Application-Gateway-Ports"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "65200-65535"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = var.tags
}

resource "azurerm_subnet_network_security_group_association" "assoc_public" {
  subnet_id                 = azurerm_subnet.public.id
  network_security_group_id = azurerm_network_security_group.this.id
}