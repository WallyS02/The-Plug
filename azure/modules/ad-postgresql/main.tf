resource "azurerm_postgresql_server" "this" {
  name                = "${var.postgres_name}-database-server"
  location            = var.location
  resource_group_name = var.resource_group_name

  administrator_login          = var.administrator_login
  administrator_login_password = var.administrator_password

  sku_name              = var.sku_name
  version               = var.version
  storage_mb            = var.storage_mb
  backup_retention_days = 7

  ssl_enforcement_enabled       = true
  public_network_access_enabled = false

  tags = var.tags
}

resource "azurerm_postgresql_database" "this" {
  name                = "${var.postgres_name}-database"
  resource_group_name = var.resource_group_name
  server_name         = azurerm_postgresql_server.this.name
  charset             = "UTF8"
  collation           = "English_United States.1252"

  lifecycle {
    prevent_destroy = true
  }
}