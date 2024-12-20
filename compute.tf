
resource "azurerm_virtual_machine" "longlegs" {
  name                  = "longlegs-vm"
  location              = azurerm_resource_group.longlegs.location
  resource_group_name   = azurerm_resource_group.longlegs.name
  network_interface_ids = [azurerm_network_interface.longlegs.id]
  vm_size               = "Standard_B2s"

  tags = var.common_tags

  storage_os_disk {
    name              = "longlegs-os-disk"
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
    computer_name  = "longlegs-vm"
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

# Create user assigned managed identity
resource "azurerm_user_assigned_identity" "n8n_identity" {
  name                = "n8n-managed-identity"
  resource_group_name = azurerm_resource_group.longlegs.name
  location            = azurerm_resource_group.longlegs.location
}

// Assign Key Vault Secrets User role to the managed identity
resource "azurerm_role_assignment" "keyvault_role" {
  scope                = azurerm_key_vault.longlegs.id
  role_definition_id   = data.azurerm_role_definition.kv_secrets_user.id
  principal_id         = azurerm_user_assigned_identity.n8n_identity.principal_id
}
