terraform {
  backend "azurerm" {
    resource_group_name  = "rg-tfstate"
    storage_account_name = "stdevsecopstfstate01"
    container_name       = "tfstate"
    key                  = "devsecops.tfstate"
  }
}
