provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {}
variable "location" {
  default = "Central India"
}

variable "rg_name" {
  default = "rg-devsecops"
}
resource "azurerm_virtual_network" "vnet" {
 name = "devsecops-vnet"
 address_space = ["10.0.0.0/16"]
 resource_group_name = var.rg_name
 location = var.location
}
resource "azurerm_subnet" "subnet" {
  name = "devsecops-subnet"
  resource_group_name = var.rg_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes = ["10.0.1.0/24"]
}
resource "azurerm_public_ip" "pip" {
  name = "public-pip"
  resource_group_name = var.rg_name
  location = var.location
  allocation_method = "Static"
}
resource "azurerm_network_interface" "nic"{
  name = "devsecops-nic"
  location = var.location
  resource_group_name = var.rg_name
  ip_configuration {
    name = "internal"
    subnet_id = azurerm_subnet.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip.id
    }
}
