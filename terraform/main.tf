resource "azurerm_resource_group" "longlegs" {
  name     = "${var.resource_prefix}-resources"
  location = var.location

  tags = var.common_tags
}

module "keyvault" {
  source              = "./modules/keyvault"
  resource_group_name = azurerm_resource_group.longlegs.name
  location            = azurerm_resource_group.longlegs.location
  resource_prefix     = var.resource_prefix
  path_to_license_file = var.path_to_license_file
  postgres_password   = var.postgres_password
  common_tags         = var.common_tags
}

module "network" {
  source              = "./modules/network"
  resource_group_name = azurerm_resource_group.longlegs.name
  location            = azurerm_resource_group.longlegs.location
  resource_prefix     = var.resource_prefix
  common_tags         = var.common_tags
}

module "compute" {
  source              = "./modules/compute"
  resource_group_name = azurerm_resource_group.longlegs.name
  location            = azurerm_resource_group.longlegs.location
  resource_prefix     = var.resource_prefix
  network_interface_id = module.network.network_interface_id
  ansible_user        = var.ansible_user
  key_vault_id        = module.keyvault.key_vault_id
  common_tags         = var.common_tags
}

module "database" {
  source                = "./modules/database"
  resource_group_name   = azurerm_resource_group.longlegs.name
  location              = azurerm_resource_group.longlegs.location
  resource_prefix       = var.resource_prefix
  virtual_network_name  = module.network.virtual_network_name
  kubernetes_subnet_cidr = var.kubernetes_subnet_cidr
  vm_public_ip          = module.network.public_ip
  postgres_password     = var.postgres_password
  common_tags           = var.common_tags
}
