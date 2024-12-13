terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }

  required_version = ">= 0.12"
}
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "longlegs" {
  name     = "longlegs-resources"
  location = "North Europe"
}

resource "azurerm_virtual_network" "longlegs" {
  name                = "longlegs-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.longlegs.location
  resource_group_name = azurerm_resource_group.longlegs.name
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
}

resource "azurerm_public_ip" "longlegs" {
  name                = "longlegs-pip"
  location            = azurerm_resource_group.longlegs.location
  resource_group_name = azurerm_resource_group.longlegs.name
  allocation_method   = "Dynamic"
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
  vm_size               = "Standard_B1ls"

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
    admin_username = "adminuser"
    admin_password = var.admin_password
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }
}

variable "admin_password" {
  description = "The admin password for the virtual machine"
  type        = string
  sensitive   = true
}