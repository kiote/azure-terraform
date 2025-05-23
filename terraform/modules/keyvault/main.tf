data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "this" {
  name                = "${var.resource_prefix}-keyvault"
  location            = var.location
  resource_group_name = var.resource_group_name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"

  purge_protection_enabled  = true
  enable_rbac_authorization = true

  tags = var.common_tags
}

data "azurerm_role_definition" "kv_contributor" {
  name  = "Key Vault Contributor"
  scope = azurerm_key_vault.this.id
}

data "azurerm_role_definition" "kv_secrets_user" {
  name  = "Key Vault Secrets User"
  scope = azurerm_key_vault.this.id
}

resource "azurerm_role_assignment" "terraform_keyvault_contributor" {
  scope              = azurerm_key_vault.this.id
  role_definition_id = data.azurerm_role_definition.kv_contributor.id
  principal_id       = data.azurerm_client_config.current.object_id
}

resource "azurerm_role_assignment" "terraform_keyvault_secrets_user" {
  scope              = azurerm_key_vault.this.id
  role_definition_id = data.azurerm_role_definition.kv_secrets_user.id
  principal_id       = data.azurerm_client_config.current.object_id
}

resource "azurerm_key_vault_secret" "license_file" {
  name         = "license-file"
  value        = filebase64(var.path_to_license_file)
  key_vault_id = azurerm_key_vault.this.id

  tags = var.common_tags

  depends_on = [
    azurerm_role_assignment.terraform_keyvault_contributor,
    azurerm_role_assignment.terraform_keyvault_secrets_user
  ]
}

resource "azurerm_key_vault_secret" "postgres_password" {
  name         = "postgres-password"
  value        = var.postgres_password
  key_vault_id = azurerm_key_vault.this.id

  tags = var.common_tags

  depends_on = [
    azurerm_role_assignment.terraform_keyvault_contributor,
    azurerm_role_assignment.terraform_keyvault_secrets_user
  ]
}

output "key_vault_id" {
  value = azurerm_key_vault.this.id
}
