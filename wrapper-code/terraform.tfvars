cluster_name                = "prod-aks"
prefix                      = "testamart"
admin_username              = "azureuser"
agents_count                = 1

sku_tier                                = "Standard"
network_policy                          = "calico"
network_plugin                          = "kubenet"
net_profile_dns_service_ip              = "10.7.0.10"
net_profile_docker_bridge_cidr          = "10.6.0.1/21"
net_profile_outbound_type               = "loadBalancer"
net_profile_pod_cidr                    = "10.6.0.0/16"
net_profile_service_cidr                = "10.7.0.0/21"
kubernetes_version                      = "1.28.3"
agents_availability_zones               = []
orchestrator_version                    = "1.28.3"
agents_pool_name                        = "nodepool"
agents_size                             = "Standard_B8als_v2"
os_disk_size_gb                         = "50"
enable_auto_scaling                     = false
agents_max_count                        = 1
agents_min_count                        = 1
agents_labels                           = { instance-type = "B8als_v2", lifecycle = "Regular" , workload = "monit-logging" }
agents_type                             = "VirtualMachineScaleSets"
client_id                               = "e54454te-cda5-4661-95e3-5e6fe54a223a"
client_secret                           = "Au33Q~dO9.Sd4bwTU6M-Iwyf5t04riDUh33YKbwf"
enable_ingress_application_gateway      = null
enable_log_analytics_workspace = false
agents_tags = {
  role = "AKS"
  type = "cluster"
  env = "prod"
}
tags   = {
    platform = "Azure"
    owner    = "Opstree"
    env      = "prod"
  }
agents_max_pods         = 100
identity_type           = "SystemAssigned"
private_cluster_enabled = true

additional_node_pools = {
  backendpool= {
    node_count_add                     = 1
    vm_size_add                        = "Standard_F8s_v2"
    zones_add                          = []
    max_pods_add                       = 100
    os_disk_size_gb_add                = 50
    labels_add                         = {
      instance-type = "F8s_v2"
      lifecycle = "on-demand"
      workload = "backend-app"

    }
    taints_add = []
    node_os_add                        = "Linux"
    cluster_auto_scaling_add           = true
    cluster_auto_scaling_min_count_add = 1
    cluster_auto_scaling_max_count_add = 3
    priority =   ""
    eviction_policy = ""
    spot_max_price  = null
  },
  frontendpool = {
    node_count_add      = 1
    vm_size_add         = "Standard_F8s_v2"
    zones_add           = []
    max_pods_add        = 100
    os_disk_size_gb_add = 50
    labels_add                         = {
      instance-type = "F8s_v2"
      lifecycle = "on-demand"
      workload = "frontend-app"
    }
    taints_add                         = []
    node_os_add                        = "Linux"
    cluster_auto_scaling_add           = true
    cluster_auto_scaling_min_count_add = 2
    cluster_auto_scaling_max_count_add = 3
    priority =   ""
    eviction_policy = ""
    spot_max_price  = null
  },
}
