// VNet and Subnets
resource "azurerm_virtual_network" "this" {
  name                = "${var.vnet_name}-vnet"
  resource_group_name = var.resource_group_name
  location            = var.location
  address_space       = var.address_space
  tags                = var.tags
}

resource "azurerm_subnet" "public_a" {
  name                 = "${var.vnet_name}-public-subnet-a"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = [var.public_subnet_a_prefix]

  service_endpoints = ["Microsoft.KeyVault"]
}

resource "azurerm_subnet" "public_b" {
  name                 = "${var.vnet_name}-private-subnet-b"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = [var.public_subnet_b_prefix]

  service_endpoints = ["Microsoft.KeyVault"]
}

resource "azurerm_subnet" "private" {
  name                 = "${var.vnet_name}-private-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = [var.private_subnet_prefix]
  
  service_endpoints = ["Microsoft.KeyVault"]
}

// NSG for public subnets
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

  tags = var.tags
}

resource "azurerm_subnet_network_security_group_association" "assoc_public_a" {
  subnet_id                 = azurerm_subnet.public_a.id
  network_security_group_id = azurerm_network_security_group.this.id
}

resource "azurerm_subnet_network_security_group_association" "assoc_public_b" {
  subnet_id                 = azurerm_subnet.public_b.id
  network_security_group_id = azurerm_network_security_group.this.id
}

// Public IP for NAT Gateway
resource "azurerm_public_ip" "nat-pip" {
  name                = "${var.vnet_name}-pip-nat"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = var.public_ip_sku
  tags                = var.tags
}

// NAT Gateway
resource "azurerm_nat_gateway" "this" {
  name                = "${var.vnet_name}-nat-gateway"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku_name            = var.nat_gateway_sku
  tags                = var.tags
}

// Associate NAT Gateway to Public IP
resource "azurerm_nat_gateway_public_ip_association" "this" {
  public_ip_address_id = azurerm_public_ip.nat-pip.id
  nat_gateway_id       = azurerm_nat_gateway.this.id
}

// Associate NAT Gateway to private subnet
resource "azurerm_subnet_nat_gateway_association" "assoc_private_a" {
  subnet_id      = azurerm_subnet.private.id
  nat_gateway_id = azurerm_nat_gateway.this.id
}