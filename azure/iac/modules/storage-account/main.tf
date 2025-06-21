resource "azurerm_storage_account" "this" {
  name                     = "${var.storage_account_name}storageaccount"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = var.sku_tier
  account_replication_type = var.account_replication_type
  access_tier              = var.access_tier
  tags                     = var.tags
}

resource "azurerm_storage_account_static_website" "this" {
  storage_account_id = azurerm_storage_account.this.id
  index_document     = "index.html"
  error_404_document = "404.html"
}