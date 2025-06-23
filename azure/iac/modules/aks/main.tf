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
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.aks_identity.id]
  }

  kubelet_identity {
    client_id                 = azurerm_user_assigned_identity.kubelet_identity.client_id
    object_id                 = azurerm_user_assigned_identity.kubelet_identity.principal_id
    user_assigned_identity_id = azurerm_user_assigned_identity.kubelet_identity.id
  }

  key_vault_secrets_provider {
    secret_rotation_enabled = true
  }

  tags = var.tags

  depends_on = [azurerm_key_vault_access_policy.aks_policy, azurerm_role_assignment.aks_agw_contributor, azurerm_role_assignment.kubelet_acr_pull, azurerm_role_assignment.kubelet_mi_operator, azurerm_key_vault_access_policy.aks_kubelet_policy]
}

data "azurerm_client_config" "current" {}

resource "azurerm_user_assigned_identity" "kubelet_identity" {
  name                = "${var.aks_name}-kubelet-identity"
  resource_group_name = var.resource_group_name
  location            = var.location
}

resource "azurerm_role_assignment" "kubelet_acr_pull" {
  principal_id                     = azurerm_user_assigned_identity.kubelet_identity.principal_id
  role_definition_name             = "AcrPull"
  scope                            = var.acr_id
  skip_service_principal_aad_check = true
}

resource "azurerm_key_vault_access_policy" "aks_kubelet_policy" {
  key_vault_id = var.key_vault_id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_user_assigned_identity.kubelet_identity.principal_id

  secret_permissions = ["Get", "List"]
}

resource "azurerm_user_assigned_identity" "aks_identity" {
  name                = "${var.aks_name}-identity"
  resource_group_name = var.resource_group_name
  location            = var.location
}

resource "azurerm_key_vault_access_policy" "aks_policy" {
  key_vault_id = var.key_vault_id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_user_assigned_identity.aks_identity.principal_id

  secret_permissions = ["Get", "List"]
}

resource "azurerm_role_assignment" "aks_agw_contributor" {
  scope                = var.gateway_id
  role_definition_name = "Contributor"
  principal_id         = azurerm_user_assigned_identity.aks_identity.principal_id
}

resource "azurerm_role_assignment" "kubelet_mi_operator" {
  scope                = azurerm_user_assigned_identity.kubelet_identity.id
  role_definition_name = "Managed Identity Operator"
  principal_id         = azurerm_user_assigned_identity.aks_identity.principal_id
}