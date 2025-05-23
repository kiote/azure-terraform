resource "azurerm_subnet" "postgres" {
  name                 = "postgres-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.virtual_network_name
  address_prefixes     = ["10.0.3.0/24"]
}

resource "azurerm_network_security_group" "postgres" {
  name                = "postgres-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.common_tags
}

resource "azurerm_network_security_rule" "postgres" {
  name                        = "allow-postgres"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "5432"
  source_address_prefix       = var.kubernetes_subnet_cidr
  destination_address_prefix  = azurerm_subnet.postgres.address_prefixes[0]
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.postgres.name
}

resource "azurerm_subnet_network_security_group_association" "postgres" {
  subnet_id                 = azurerm_subnet.postgres.id
  network_security_group_id = azurerm_network_security_group.postgres.id
}

resource "azurerm_postgresql_flexible_server" "this" {
  name                = "n8n-${var.resource_prefix}-postgres"
  resource_group_name = var.resource_group_name
  location            = var.location
  version             = "16"
  zone                = "2"

  sku_name   = "B_Standard_B1ms"
  storage_mb = 32768

  administrator_login    = "psqladmin"
  administrator_password = var.postgres_password

  public_network_access_enabled = true

  authentication {
    password_auth_enabled         = true
    active_directory_auth_enabled = false
  }

  tags = var.common_tags
}

resource "azurerm_postgresql_flexible_server_database" "this" {
  name      = "${var.resource_prefix}_db"
  server_id = azurerm_postgresql_flexible_server.this.id
  charset   = "UTF8"
  collation = "en_US.utf8"
}

resource "azurerm_postgresql_flexible_server_firewall_rule" "vm_access" {
  name             = "allow-vm-access"
  server_id        = azurerm_postgresql_flexible_server.this.id
  start_ip_address = var.vm_public_ip
  end_ip_address   = var.vm_public_ip
}

resource "azurerm_postgresql_flexible_server_configuration" "postgres_config" {
  server_id = azurerm_postgresql_flexible_server.this.id
  name      = "ssl_min_protocol_version"
  value     = "TLSv1.2"
}

resource "azurerm_postgresql_flexible_server_configuration" "pgaudit_log" {
  server_id = azurerm_postgresql_flexible_server.this.id
  name      = "pgaudit.log"
  value     = "all"
}
