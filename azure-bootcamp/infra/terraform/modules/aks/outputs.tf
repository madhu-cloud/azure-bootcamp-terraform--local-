output "kube_config" {
  value       = azurerm_kubernetes_cluster.aks.kube_config_raw
  description = "Kubernetes configuration"
  sensitive   = true
}

output "cluster_id" {
  value       = azurerm_kubernetes_cluster.aks.id
  description = "AKS cluster ID"
}

output "cluster_name" {
  value       = azurerm_kubernetes_cluster.aks.name
  description = "AKS cluster name"
}
