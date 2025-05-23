resource "azurerm_user_assigned_identity" "n8n_identity" {
  name                = "n8n-managed-identity"
  resource_group_name = var.resource_group_name
  location            = var.location
}

data "azurerm_role_definition" "kv_secrets_user" {
  name  = "Key Vault Secrets User"
  scope = var.key_vault_id
}

resource "azurerm_role_assignment" "keyvault_role" {
  scope              = var.key_vault_id
  role_definition_id = data.azurerm_role_definition.kv_secrets_user.id
  principal_id       = azurerm_user_assigned_identity.n8n_identity.principal_id
}

resource "azurerm_virtual_machine" "this" {
  name                  = "${var.resource_prefix}-vm"
  location              = var.location
  resource_group_name   = var.resource_group_name
  network_interface_ids = [var.network_interface_id]
  vm_size               = "Standard_B2s"

  tags = var.common_tags

  storage_os_disk {
    name              = "${var.resource_prefix}-os-disk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  storage_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  os_profile {
    computer_name  = "${var.resource_prefix}-vm"
    admin_username = var.ansible_user
  }

  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      path     = "/home/${var.ansible_user}/.ssh/authorized_keys"
      key_data = file("~/.ssh/id_ed25519.pub")
    }
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.n8n_identity.id]
  }
}

output "identity_client_id" {
  value = azurerm_user_assigned_identity.n8n_identity.client_id
}
