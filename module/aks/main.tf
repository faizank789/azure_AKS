resource "azurerm_user_assigned_identity" "aks_identity" {
  count               = var.identity_type == "UserAssigned" ? 1 : 0
  resource_group_name = var.resource_group_name
  location            = var.location
  name                = var.user_assigned_identity_name
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                              = var.cluster_name == null ? "${var.prefix}-aks" : var.cluster_name
  kubernetes_version                = var.kubernetes_version
  location                          = var.location
  resource_group_name               = var.resource_group_name
  dns_prefix                        = var.prefix
  sku_tier                          = var.sku_tier
  private_cluster_enabled           = var.private_cluster_enabled
  http_application_routing_enabled  = var.enable_http_application_routing
  azure_policy_enabled              = var.enable_azure_policy
  role_based_access_control_enabled = var.enable_role_based_access_control

  linux_profile {
    admin_username = var.admin_username

    ssh_key {
      key_data = var.key_data
    }
    
  }


  dynamic "default_node_pool" {
    for_each = var.agents_pool_name == "nodepool" ? ["default_node_pool"] : []
    content {
      orchestrator_version   = var.orchestrator_version
      name                   = var.agents_pool_name
      node_count             = var.agents_count
      vm_size                = var.agents_size
      os_disk_size_gb        = var.os_disk_size_gb
      vnet_subnet_id         = var.vnet_subnet_id
      enable_auto_scaling    = var.enable_auto_scaling
      max_count              = var.enable_auto_scaling == true ? var.agents_max_count : null
      min_count              = var.enable_auto_scaling == true ? var.agents_min_count : null
      enable_node_public_ip  = var.enable_node_public_ip
      # availability_zones     = var.agents_availability_zones
      node_labels            = var.agents_labels
      type                   = var.agents_type
      tags                   = merge(var.tags, var.agents_tags)
      max_pods               = var.agents_max_pods
      enable_host_encryption = var.enable_host_encryption
    }
  }

  dynamic "service_principal" {
    for_each = var.client_id != "" && var.client_secret != "" ? ["service_principal"] : []
    content {
      client_id     = var.client_id
      client_secret = var.client_secret
    }
  }

  dynamic "identity" {
    for_each = var.client_id == "" || var.client_secret == "" ? ["identity"] : []
    content {
      type                      = var.identity_type
      # user_assigned_identity_id = var.identity_type == "UserAssigned" ? azurerm_user_assigned_identity.aks_identity[0].id : null
    }
  }

  # oms_agent {
  #   log_analytics_workspace_id = var.enable_log_analytics_workspace ? azurerm_log_analytics_workspace.log[0].id : null
  # }

  dynamic "ingress_application_gateway" {
    for_each = var.enable_ingress_application_gateway == null ? [] : ["ingress_application_gateway"]
    content {
      gateway_id   = var.ingress_application_gateway_id
      gateway_name = var.ingress_application_gateway_name
      subnet_cidr  = var.ingress_application_gateway_subnet_cidr
      subnet_id    = var.ingress_application_gateway_subnet_id
    }
  }

  dynamic "azure_active_directory_role_based_access_control" {
    for_each = var.enable_role_based_access_control && var.rbac_aad_managed ? [1] : []
    content {
      managed                = var.rbac_aad_managed
      admin_group_object_ids = var.rbac_aad_admin_group_object_ids
      azure_rbac_enabled     = var.enable_role_based_access_control
    }
  }

  network_profile {
    network_plugin     = var.network_plugin == var.network_policy ? var.network_plugin : "kubenet"
    network_policy     = var.network_policy
    dns_service_ip     = var.net_profile_dns_service_ip
    docker_bridge_cidr = var.net_profile_docker_bridge_cidr
    outbound_type      = var.net_profile_outbound_type
    pod_cidr           = var.network_plugin == "kubenet" ? var.net_profile_pod_cidr : null
    service_cidr       = var.net_profile_service_cidr
  }

  tags = var.tags
}

# resource "azurerm_log_analytics_workspace" "log" {
#   count               = var.enable_log_analytics_workspace ? 1 : 0
#   name                = var.cluster_log_analytics_workspace_name == null ? "${var.prefix}-workspace" : var.cluster_log_analytics_workspace_name
#   location            = var.location
#   resource_group_name = var.resource_group_name
#   sku                 = var.log_analytics_workspace_sku
#   retention_in_days   = var.log_retention_in_days

#   tags = var.tags
# }

resource "azurerm_kubernetes_cluster_node_pool" "aks" {
  lifecycle {
    ignore_changes = [
      node_count
    ]
  }

  for_each              = var.additional_node_pools
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks.id
  name                  = lower(each.key)
  orchestrator_version  = var.kubernetes_version
  node_count            = each.value.node_count_add
  vm_size               = each.value.vm_size_add
  max_pods              = each.value.max_pods_add
  os_disk_size_gb       = each.value.os_disk_size_gb_add
  os_type               = each.value.node_os_add
  vnet_subnet_id        = var.vnet_subnet_id
  node_labels           = each.value.labels_add

node_taints = each.value.taints_add

  enable_auto_scaling   = each.value.cluster_auto_scaling_add
  min_count             = each.value.cluster_auto_scaling_min_count_add > 0 ? each.value.cluster_auto_scaling_min_count_add : null
  max_count             = each.value.cluster_auto_scaling_max_count_add > 0 ? each.value.cluster_auto_scaling_max_count_add : null
  enable_node_public_ip = false
  priority=  each.value.priority == "" ? null :each.value.priority 
  eviction_policy= each.value.priority == "" ? null : each.value.eviction_policy
  spot_max_price= each.value.priority == "" ? null : each.value.spot_max_price
}
