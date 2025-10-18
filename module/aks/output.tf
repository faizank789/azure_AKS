output "aks_id" {
  description = "AKS resource id"
  value       = azurerm_kubernetes_cluster.aks.id
}

output "aks_name" {
  description = "Name of the AKS cluster"
  value       = split("/", azurerm_kubernetes_cluster.aks.id)[8]
}

output "aks_nodes_rg" {
  description = "Name of the resource group in which AKS nodes are deployed"
  value       = azurerm_kubernetes_cluster.aks.node_resource_group
}

output "kubelet_identity" {
  description = "The User Managed Identity used by AKS Agents"
  value       = azurerm_kubernetes_cluster.aks.kubelet_identity
}
