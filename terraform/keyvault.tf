resource "azurerm_key_vault" "longlegs" {
  name                = "${var.resource_prefix}-keyvault"
  location            = azurerm_resource_group.longlegs.location
  resource_group_name = azurerm_resource_group.longlegs.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"

  purge_protection_enabled  = true
  enable_rbac_authorization = true

  tags = var.common_tags
}

resource "azurerm_key_vault_secret" "license_file" {
  name         = "license-file"
  value        = filebase64("${var.path_to_license_file}")
  key_vault_id = azurerm_key_vault.longlegs.id

  tags = var.common_tags

  depends_on = [
    azurerm_role_assignment.terraform_keyvault_contributor,
    azurerm_role_assignment.terraform_keyvault_secrets_user
  ]
}

# Assign Key Vault Contributor role to the Terraform execution identity
resource "azurerm_role_assignment" "terraform_keyvault_contributor" {
  scope              = azurerm_key_vault.longlegs.id
  role_definition_id = data.azurerm_role_definition.kv_contributor.id
  principal_id       = data.azurerm_client_config.current.object_id
}

# Assign Key Vault Secrets User role to the Terraform execution identity
resource "azurerm_role_assignment" "terraform_keyvault_secrets_user" {
  scope              = azurerm_key_vault.longlegs.id
  role_definition_id = data.azurerm_role_definition.kv_secrets_user.id
  principal_id       = data.azurerm_client_config.current.object_id
}

# Store the PostgreSQL password in Key Vault
resource "azurerm_key_vault_secret" "postgres_password" {
  name         = "postgres-password"
  value        = var.postgres_password
  key_vault_id = azurerm_key_vault.longlegs.id

  tags = var.common_tags

  depends_on = [
    azurerm_role_assignment.terraform_keyvault_contributor,
    azurerm_role_assignment.terraform_keyvault_secrets_user
  ]
}
