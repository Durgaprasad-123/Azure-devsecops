resource "random_string" "aks_suffix" {
  length  = 5
  special = false
  upper   = false
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = "aks${random_string.aks_suffix.result}"
  location            = var.location
  resource_group_name = var.rg_name
  dns_prefix          = "aks${random_string.aks_suffix.result}"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size = "Standard_D2s_v3"
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    Environment = "DevSecOps"
    Project     = "Azure-DevSecOps"
  }
}
