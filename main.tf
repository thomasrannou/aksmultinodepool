locals {
  tags = {
      projet      = "Demo"
      environment = "Dev"
    }
}

terraform {
  backend "azurerm" {
    resource_group_name   = "rg-demo-dev-fr"
    storage_account_name  = "sademodevfrtest"
    container_name        = "terraformdeployment"
    key                   = "terraform.tfstate"
  }
}

# ======================================================================================
# Resource Group
# ======================================================================================
 resource "azurerm_resource_group" "tf-rg-aks-01" {
    name        = "${var.aks-resource-group-name}"
    location    = "${var.aks-resource-group-location}"
    tags        = "${local.tags}"
 }

# ======================================================================================
# Cluster kubernetes
# ======================================================================================
resource "azurerm_kubernetes_cluster" "cluster-aks" {
  name                    = "${var.aks-cluster-name}"
  location                = "${azurerm_resource_group.tf-rg-aks-01.location}"
  resource_group_name     = "${azurerm_resource_group.tf-rg-aks-01.name}"   
  kubernetes_version      = "1.22.2"
  dns_prefix              = "${var.aks-cluster-name}-dns"
  tags                    = "${local.tags}"
   
  default_node_pool {
    name                  = "default"
    vm_size               = "Standard_D2_v2"
    enable_auto_scaling   = false
    node_count            = 3
    availability_zones    = ["1", "2", "3"]
    type                  = "VirtualMachineScaleSets"
  }

  network_profile {
    network_plugin = "azure"
    load_balancer_sku = "standard"
  }

  service_principal {
    client_id     = "${var.aks-cluster-sp-client-id}"
    client_secret = "${var.aks-cluster-sp-client-secret}"
  }
}

resource "azurerm_kubernetes_cluster_node_pool" "nodepoolcpu" {
  availability_zones    = [1, 2, 3]
  enable_auto_scaling   = true
  kubernetes_cluster_id = azurerm_kubernetes_cluster.cluster-aks.id
  max_count             = 3
  min_count             = 1
  mode                  = "User"
  name                  = "nodepoolcpu"
  os_disk_size_gb       = 30
  os_type               = "Linux"
  vm_size               = "Standard_F2S_v2"
}

resource "azurerm_kubernetes_cluster_node_pool" "nodepooldev" {
  enable_auto_scaling   = true
  kubernetes_cluster_id = azurerm_kubernetes_cluster.cluster-aks.id
  max_count             = 3
  min_count             = 1
  mode                  = "User"
  name                  = "nodepooldev"
  os_disk_size_gb       = 30
  os_type               = "Linux"
  vm_size               = "standard_a2_v2"
  priority              = "Spot"  
  eviction_policy       = "Delete"
  spot_max_price  = -1 # note: this is the "maximum" price
  node_labels = {
    "kubernetes.azure.com/scalesetpriority" = "spot"
  }
  node_taints = [
    "kubernetes.azure.com/scalesetpriority=spot:NoSchedule"
  ]
  tags = {
    "nodepool-type" = "user"
    "environment"   = "production"
    "nodepoolos"    = "linux"
    "app"           = "dotnet-apps"
  }
}