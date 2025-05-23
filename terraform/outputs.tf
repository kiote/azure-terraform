output "vm_public_ip" {
  value = azurerm_public_ip.longlegs.ip_address
}

output "n8n_identity_client_id" { # For debugging purposes
  value = azurerm_user_assigned_identity.n8n_identity.client_id
}
