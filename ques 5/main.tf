provider "azurerm" {
  features {}
}

# Variables
variable "resource_group_name" {
  default = "myResourceGroup"
}

variable "location" {
  default = "East US"
}

variable "aks_cluster_name" {
  default = "myAKSCluster"
}

variable "node_count" {
  default = 3
}

variable "node_size" {
  default = "Standard_DS2_v2"
}

# Create Resource Group
resource "azurerm_resource_group" "aks_rg" {
  name     = var.resource_group_name
  location = var.location
}

# Create AKS Cluster
resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.aks_cluster_name
  location            = azurerm_resource_group.aks_rg.location
  resource_group_name = azurerm_resource_group.aks_rg.name
  dns_prefix          = var.aks_cluster_name

  default_node_pool {
    name       = "default"
    node_count = var.node_count
    vm_size   = var.node_size
  }

  identity {
    type = "SystemAssigned"
  }

  # Enable monitoring
  addon_profile {
    oms_agent {
      enabled = true
      log_analytics_workspace_id = azurerm_log_analytics_workspace.aks_workspace.id
    }
  }

  tags = {
    Environment = "Dev"
  }
}

# Create Log Analytics Workspace
resource "azurerm_log_analytics_workspace" "aks_workspace" {
  name                = "${var.aks_cluster_name}-workspace"
  location            = azurerm_resource_group.aks_rg.location
  resource_group_name = azurerm_resource_group.aks_rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30

  tags = {
    Environment = "Dev"
  }
}

output "kube_config" {
  value = azurerm_kubernetes_cluster.aks.kube_admin_config
}