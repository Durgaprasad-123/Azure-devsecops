module "networking" {
  source = "./modules/networking"

  resource_group_name = module.resource_group.name
  location            = var.location
}

module "security" {
  source = "./modules/security"

  subnet_id           = module.networking.subnet_id
  resource_group_name = module.resource_group.name
  location            = var.location
}

module "managed_identity" {
  source = "./modules/managed-identity"

  resource_group_name = module.resource_group.name
  location            = var.location
}

module "acr" {
  source = "./modules/acr"

  resource_group_name = module.resource_group.name
  location            = var.location
}

module "keyvault" {
  source = "./modules/keyvault"

  resource_group_name = module.resource_group.name
  location            = var.location
}

module "vm" {
  source = "./modules/vm"

  nic_id      = module.networking.nic_id
  identity_id = module.managed_identity.id
}
