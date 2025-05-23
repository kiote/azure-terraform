data "azurerm_client_config" "current" {}

# Data source to fetch Key Vault Contributor role definition
data "azurerm_role_definition" "kv_contributor" {
  name  = "Key Vault Contributor"
  scope = azurerm_key_vault.longlegs.id
}

# Data source to fetch Key Vault Secrets User role definition
data "azurerm_role_definition" "kv_secrets_user" {
  name  = "Key Vault Secrets User"
  scope = azurerm_key_vault.longlegs.id
}
