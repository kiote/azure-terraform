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

  // to allow letsencrypt to validate and renew the certificate
  security_rule {
    name                       = "allow-http"
    priority                   = 1003
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }


  tags = var.common_tags
}

resource "azurerm_network_interface_security_group_association" "longlegs" {
  network_interface_id      = azurerm_network_interface.longlegs.id
  network_security_group_id = azurerm_network_security_group.longlegs.id
}
