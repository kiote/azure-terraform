resource "azurerm_resource_group" "longlegs" {
  name     = "longlegs-resources"
  location = "North Europe"

  tags = var.common_tags
}

resource "azurerm_virtual_network" "longlegs" {
  name                = "longlegs-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.longlegs.location
  resource_group_name = azurerm_resource_group.longlegs.name

  tags = var.common_tags
}

resource "azurerm_subnet" "longlegs" {
  name                 = "longlegs-subnet"
  resource_group_name  = azurerm_resource_group.longlegs.name
  virtual_network_name = azurerm_virtual_network.longlegs.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "longlegs" {
  name                = "longlegs-nic"
  location            = azurerm_resource_group.longlegs.location
  resource_group_name = azurerm_resource_group.longlegs.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.longlegs.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.longlegs.id
  }

  tags = var.common_tags
}

resource "azurerm_public_ip" "longlegs" {
  name                = "longlegs-pip"
  location            = azurerm_resource_group.longlegs.location
  resource_group_name = azurerm_resource_group.longlegs.name
  allocation_method   = "Dynamic"

  tags = var.common_tags
}

resource "azurerm_network_security_group" "longlegs" {
  name                = "longlegs-nsg"
  location            = azurerm_resource_group.longlegs.location
  resource_group_name = azurerm_resource_group.longlegs.name

  security_rule {
    name                       = "allow-https"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow-ssh"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = var.common_tags
}

resource "azurerm_network_interface_security_group_association" "longlegs" {
  network_interface_id      = azurerm_network_interface.longlegs.id
  network_security_group_id = azurerm_network_security_group.longlegs.id
}

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
    admin_username = "${var.ansible_user}"
  }

  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      path     = "/home/${var.ansible_user}/.ssh/authorized_keys"
      key_data = file("~/.ssh/id_ed25519.pub")
    }
  }
}

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

data "azurerm_key_vault_secret" "license_file" {
  name         = azurerm_key_vault_secret.license_file.name
  key_vault_id = azurerm_key_vault.longlegs.id
}

resource "local_file" "license_file" {
  content  = base64decode(data.azurerm_key_vault_secret.license_file.value)
  filename = "/tmp/pysmile_license.py"
}

resource "null_resource" "copy_license_to_remote" {
  provisioner "file" {
    source      = "/tmp/pysmile_license.py"
    destination = "/tmp/pysmile_license.py"

    connection {
      type        = "ssh"
      user        = var.ansible_user
      private_key = file("~/.ssh/id_ed25519")
      host        = azurerm_public_ip.longlegs.ip_address
    }
  }

  provisioner "remote-exec" {
    inline = [
      "mkdir -p /home/${var.ansible_user}/license",
      "mv /tmp/pysmile_license.py /home/${var.ansible_user}/license/pysmile_license.py",
      "chown ${var.ansible_user}:${var.ansible_user} /home/${var.ansible_user}/license/pysmile_license.py"
    ]

    connection {
      type        = "ssh"
      user        = var.ansible_user
      private_key = file("~/.ssh/id_ed25519")
      host        = azurerm_public_ip.longlegs.ip_address
    }
  }

  depends_on = [
    local_file.license_file
  ]
}
