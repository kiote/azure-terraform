variable "resource_group_name" { type = string }
variable "location" { type = string }
variable "resource_prefix" { type = string }
variable "network_interface_id" { type = string }
variable "ansible_user" { type = string }
variable "key_vault_id" { type = string }
variable "common_tags" { type = map(string) }
