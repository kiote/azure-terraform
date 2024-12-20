# Create a subnet for PostgreSQL
resource "azurerm_subnet" "postgres" {
  name                 = "postgres-subnet"
  resource_group_name  = azurerm_resource_group.longlegs.name
  virtual_network_name = azurerm_virtual_network.longlegs.name
  address_prefixes     = ["10.0.3.0/24"]

  delegation {
    name = "fs"
    service_delegation {
      name = "Microsoft.DBforPostgreSQL/flexibleServers"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
      ]
    }
  }
}

# Create a private DNS zone for PostgreSQL
resource "azurerm_private_dns_zone" "postgres" {
  name                = "longlegs.postgres.database.azure.com"
  resource_group_name = azurerm_resource_group.longlegs.name

  tags = var.common_tags
}

# Link the DNS zone to the virtual network
resource "azurerm_private_dns_zone_virtual_network_link" "postgres" {
  name                  = "postgres-dns-link"
  private_dns_zone_name = azurerm_private_dns_zone.postgres.name
  resource_group_name   = azurerm_resource_group.longlegs.name
  virtual_network_id    = azurerm_virtual_network.longlegs.id
  registration_enabled  = true

  tags = var.common_tags
}

# Create PostgreSQL Flexible Server
resource "azurerm_postgresql_flexible_server" "longlegs" {
  name                = "longlegs-postgres"
  resource_group_name = azurerm_resource_group.longlegs.name
  location            = azurerm_resource_group.longlegs.location
  version             = "16"
  delegated_subnet_id = azurerm_subnet.postgres.id
  private_dns_zone_id = azurerm_private_dns_zone.postgres.id
  zone                = "2"

  # Most cost-effective configuration
  sku_name   = "B_Standard_B1ms"
  storage_mb = 32768 # Minimum storage (32GB)

  administrator_login    = "psqladmin"
  administrator_password = var.postgres_password

  # Disable public network access
  public_network_access_enabled = false

  authentication {
    password_auth_enabled = true
    active_directory_auth_enabled = false
  }

  depends_on = [
    azurerm_private_dns_zone_virtual_network_link.postgres
  ]

  tags = var.common_tags
}

# Create a database in the PostgreSQL server
resource "azurerm_postgresql_flexible_server_database" "longlegs" {
  name      = "longlegs_db"
  server_id = azurerm_postgresql_flexible_server.longlegs.id
  charset   = "UTF8"
  collation = "en_US.utf8"
}

resource "azurerm_postgresql_flexible_server_firewall_rule" "k8s" {
  name                = "allow-k8s-subnet"
  server_id          = azurerm_postgresql_flexible_server.longlegs.id
  start_ip_address   = cidrhost(var.kubernetes_subnet_cidr, 0)    # First IP in k8s subnet
  end_ip_address     = cidrhost(var.kubernetes_subnet_cidr, -1)   # Last IP in k8s subnet
}

# Configure PostgreSQL server parameters including access rules
resource "azurerm_postgresql_flexible_server_configuration" "postgres_config" {
  server_id = azurerm_postgresql_flexible_server.longlegs.id
  name      = "ssl_min_protocol_version"
  value     = "TLSv1.2"  # Using the minimum supported version
}

resource "azurerm_postgresql_flexible_server_configuration" "allow_subnet_access" {
  server_id = azurerm_postgresql_flexible_server.longlegs.id
  name      = "pgaudit.log"
  value     = "all"
}
