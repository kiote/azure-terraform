# Create PostgreSQL Flexible Server
# Create a separate subnet for PostgreSQL
resource "azurerm_subnet" "postgres" {
  name                 = "postgres-subnet"
  resource_group_name  = azurerm_resource_group.longlegs.name
  virtual_network_name = azurerm_virtual_network.longlegs.name
  address_prefixes     = ["10.0.3.0/24"] # Ensure this does not overlap with other subnets
}

resource "azurerm_postgresql_flexible_server" "longlegs" {
  name                = "n8n-${var.resource_prefix}-postgres"
  resource_group_name = azurerm_resource_group.longlegs.name
  location            = azurerm_resource_group.longlegs.location
  version             = "16"
  zone                = "2"

  sku_name   = "B_Standard_B1ms"
  storage_mb = 32768 # Minimum storage (32GB)

  administrator_login    = "psqladmin"
  administrator_password = var.postgres_password

  # Enable public network access
  public_network_access_enabled = true

  authentication {
    password_auth_enabled         = true
    active_directory_auth_enabled = false
  }

  tags = var.common_tags
}

# Create a database in the PostgreSQL server
resource "azurerm_postgresql_flexible_server_database" "longlegs" {
  name      = "${var.resource_prefix}_db"
  server_id = azurerm_postgresql_flexible_server.longlegs.id
  charset   = "UTF8"
  collation = "en_US.utf8"
}

# Allow traffic from the VM's public IP
resource "azurerm_postgresql_flexible_server_firewall_rule" "vm_access" {
  name             = "allow-vm-access"
  server_id        = azurerm_postgresql_flexible_server.longlegs.id
  start_ip_address = var.vm_public_ip
  end_ip_address   = var.vm_public_ip
}

# Configure PostgreSQL server parameters including access rules
resource "azurerm_postgresql_flexible_server_configuration" "postgres_config" {
  server_id = azurerm_postgresql_flexible_server.longlegs.id
  name      = "ssl_min_protocol_version"
  value     = "TLSv1.2" # Using the minimum supported version
}

resource "azurerm_postgresql_flexible_server_configuration" "pgaudit_log" {
  server_id = azurerm_postgresql_flexible_server.longlegs.id
  name      = "pgaudit.log"
  value     = "all"
}
