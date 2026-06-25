resource "azurerm_resource_group" "rg" {
  name     = var.rg_name
  location = var.location
}

module "networking" {
  source              = "./modules/networking"
  rg_name             = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
}

module "security" {
  source     = "./modules/security"
  rg_name     = azurerm_resource_group.rg.name
  location    = azurerm_resource_group.rg.location
  subnet_id   = module.networking.subnet_id
}

module "vm" {
  source     = "./modules/vm"
  rg_name     = azurerm_resource_group.rg.name
  location    = azurerm_resource_group.rg.location
  nic_id     = module.networking.nic_id
}

module "acr" {
  source     = "./modules/acr"
  rg_name     = azurerm_resource_group.rg.name
  location    = azurerm_resource_group.rg.location
}

module "keyvault" {
  source     = "./modules/keyvault"
  rg_name     = azurerm_resource_group.rg.name
  location    = azurerm_resource_group.rg.location
  tenant_id  = data.azurerm_client_config.current.tenant_id
  object_id  = data.azurerm_client_config.current.object_id
}
