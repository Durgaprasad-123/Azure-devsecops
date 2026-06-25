resource "random_string" "acr_suffix" {
  length  = 5
  special = false
  upper   = false
}

resource "azurerm_container_registry" "acr" {
  name                = "acr${random_string.acr_suffix.result}"
  resource_group_name = var.rg_name
  location            = var.location

  sku           = "Basic"
  admin_enabled = false

  tags = {
    Environment = "DevSecOps"
    Project     = "Azure-DevSecOps"
  }
}
