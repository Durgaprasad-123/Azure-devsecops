resource "azurerm_key_vault" "kv" {
  name                = "devsecopskv2026xyz"
  location            = var.location
  resource_group_name = var.rg_name

  tenant_id = var.tenant_id
  sku_name  = "standard"

  soft_delete_retention_days = 7
  purge_protection_enabled   = false
}
