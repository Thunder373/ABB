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
}

# Enable monitoring for AKS
resource "azurerm_kubernetes_cluster_monitoring" "aks_monitoring" {
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.aks_workspace.id
}

# Create CPU Alert Rule
resource "azurerm_monitor_metric_alert" "cpu_alert" {
  name                = "cpu-alert"
  resource_group_name = azurerm_resource_group.aks_rg.name
  location            = azurerm_resource_group.aks_rg.location
  description         = "Alert when CPU usage exceeds 80%"
  severity            = 2
  frequency           = "PT5M"
  window_size         = "PT5M"

  criteria {
    metric_name        = "CPU Usage"
    aggregation        = "Average"
    operator           = "GreaterThan"
    threshold          = 80
    dimensions {
      name     = "ResourceId"
      operator = "Include"
      values   = [azurerm_kubernetes_cluster.aks.id]
    }
  }

  action {
    action_group_id = azurerm_monitor_action_group.alert_action_group.id
  }
}

# Create Memory Alert Rule
resource "azurerm_monitor_metric_alert" "memory_alert" {
  name                = "memory-alert"
  resource_group_name = azurerm_resource_group.aks_rg.name
  location            = azurerm_resource_group.aks_rg.location
  description         = "Alert when memory usage exceeds 80%"
  severity            = 2
  frequency           = "PT5M"
  window_size         = "PT5M"

  criteria {
    metric_name        = "Memory Usage"
    aggregation        = "Average"
    operator           = "GreaterThan"
    threshold          = 80
    dimensions {
      name     = "ResourceId"
      operator = "Include"
      values   = [azurerm_kubernetes_cluster.aks.id]
    }
  }

  action {
    action_group_id = azurerm_monitor_action_group.alert_action_group.id
  }
}

# Create Action Group for Alerts
resource "azurerm_monitor_action_group" "alert_action_group" {
  name                = "alert-action-group"
  resource_group_name = azurerm_resource_group.aks_rg.name
  short_name          = "alertGroup"

  email_receiver {
    name          = "emailReceiver"
    email_address = "debasish@gmail.com"
  }
}