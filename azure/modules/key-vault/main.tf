resource "azurerm_key_vault" "this" {
  name                       = var.keyvault_name
  location                   = var.location
  resource_group_name        = var.resource_group_name
  tenant_id                  = var.tenant_id
  sku_name                   = "standard"
  soft_delete_retention_days = 7
  purge_protection_enabled   = false

  network_acls {
    default_action             = length(var.subnet_ids) > 0 ? "Deny" : "Allow"
    bypass                     = "AzureServices"
    ip_rules                   = []
    virtual_network_subnet_ids = var.subnet_ids
  }

  dynamic "access_policy" {
    for_each = var.object_ids
    content {
      tenant_id = var.tenant_id
      object_id = access_policy.value

      secret_permissions = [
        "get",
        "list",
        "set",
        "delete"
      ]

      key_permissions = [
        "get",
        "list"
      ]
    }
  }

  tags = var.tags
}