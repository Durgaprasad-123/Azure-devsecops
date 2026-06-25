terraform {
  backend "azurerm" {
    resource_group_name  = "rg-tfstate"
    storage_account_name = "sadevsecopstfstate01"
    container_name       = "tfstate"
    key                  = "devsecops.tfstate"
  }
}
