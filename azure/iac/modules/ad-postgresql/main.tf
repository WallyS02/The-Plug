resource "azurerm_postgresql_flexible_server" "this" {
  name                = "${var.postgres_name}-database-server"
  location            = var.location
  resource_group_name = var.resource_group_name

  administrator_login    = var.administrator_login
  administrator_password = var.administrator_password

  sku_name              = var.sku_name
  version               = var.postgresql_version
  storage_mb            = var.storage_mb
  backup_retention_days = 7

  public_network_access_enabled = false

  tags = var.tags

  lifecycle {
    ignore_changes = [zone]
  }
}

resource "azurerm_postgresql_flexible_server_database" "this" {
  name      = "${var.postgres_name}-database"
  server_id = azurerm_postgresql_flexible_server.this.id
  charset   = "UTF8"
  collation = "en_US.utf8"

  /*lifecycle {
    prevent_destroy = true
  }*/
}