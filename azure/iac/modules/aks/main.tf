resource "azurerm_kubernetes_cluster" "this" {
  name                      = var.aks_name
  location                  = var.location
  resource_group_name       = var.resource_group_name
  dns_prefix                = var.dns_prefix
  automatic_upgrade_channel = "patch"
  node_os_upgrade_channel   = "SecurityPatch"

  default_node_pool {
    name            = "agentpool"
    node_count      = var.agent_count
    vm_size         = var.agent_vm_size
    vnet_subnet_id  = var.vnet_subnet_id
    max_pods        = 110
    os_disk_size_gb = 30
    tags            = var.tags
  }

  ingress_application_gateway {
    gateway_id = var.gateway_id
  }

  oidc_issuer_enabled = true

  network_profile {
    network_plugin = "azure"
    network_policy = "azure"
    service_cidr   = var.service_cidr
    dns_service_ip = var.dns_service_ip
  }

  identity {
    type = "SystemAssigned"
  }

  tags = var.tags
}

resource "azurerm_role_assignment" "this" {
  principal_id                     = azurerm_kubernetes_cluster.this.kubelet_identity[0].object_id
  role_definition_name             = "AcrPull"
  scope                            = var.acr_id
  skip_service_principal_aad_check = true
}

data "azurerm_client_config" "current" {}

resource "azurerm_key_vault_access_policy" "aks_policy" {
  key_vault_id = var.key_vault_id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_kubernetes_cluster.this.identity[0].principal_id

  secret_permissions = ["Get", "List"]
}

resource "azurerm_role_assignment" "aks_agw_contributor" {
  scope                = var.gateway_id
  role_definition_name = "Contributor"
  principal_id         = azurerm_kubernetes_cluster.this.identity[0].principal_id
}