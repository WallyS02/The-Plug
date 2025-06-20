output "aks_cluster_id" {
  description = "AKS cluster ID"
  value       = azurerm_kubernetes_cluster.this.id
}

output "aks_fqdn" {
  description = "AKS cluster API server FQDN"
  value       = azurerm_kubernetes_cluster.this.fqdn
}

output "aks_client_certificate" {
  description = "Client certificate (base64)"
  value       = azurerm_kubernetes_cluster.this.kube_config.0.client_certificate
  sensitive   = true
}

output "aks_managed_identity_principal_id" {
  description = "Assigned Managed Identity Principal ID"
  value       = azurerm_kubernetes_cluster.this.identity[0].principal_id
}