resource "azurerm_container_registry" "acr" {
  name                = "acrdevsecops2026xyz"
  resource_group_name = var.rg_name
  location            = var.location
  sku                 = "Basic"
  admin_enabled       = false
}
