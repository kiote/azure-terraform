resource "azurerm_key_vault" "longlegs" {
  name                        = "longlegs-keyvault"
  location                    = azurerm_resource_group.longlegs.location
  resource_group_name         = azurerm_resource_group.longlegs.name
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  sku_name                    = "standard"

  purge_protection_enabled    = true

  tags = var.common_tags
}

resource "azurerm_key_vault_access_policy" "longlegs" {
  key_vault_id = azurerm_key_vault.longlegs.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  secret_permissions = [
    "Get",
    "List",
    "Set",
    "Delete",
    "Recover",
    "Backup",
    "Restore",
  ]
}

resource "azurerm_key_vault_secret" "license_file" {
  name         = "license-file"
  value        = filebase64("${var.path_to_license_file}")
  key_vault_id = azurerm_key_vault.longlegs.id

  tags = var.common_tags

  depends_on = [
    azurerm_key_vault_access_policy.longlegs
  ]
}

# Store the PostgreSQL password in Key Vault
resource "azurerm_key_vault_secret" "postgres_password" {
  name         = "postgres-password"
  value        = var.postgres_password
  key_vault_id = azurerm_key_vault.longlegs.id

  tags = var.common_tags

  depends_on = [
    azurerm_key_vault_access_policy.longlegs
  ]
}
