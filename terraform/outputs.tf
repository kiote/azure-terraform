output "vm_public_ip" {
  value = module.network.public_ip
}

output "n8n_identity_client_id" {
  value = module.compute.identity_client_id
}
