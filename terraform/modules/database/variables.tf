variable "resource_group_name" { type = string }
variable "location" { type = string }
variable "resource_prefix" { type = string }
variable "virtual_network_name" { type = string }
variable "kubernetes_subnet_cidr" { type = string }
variable "vm_public_ip" { type = string }
variable "postgres_password" { type = string }
variable "common_tags" { type = map(string) }
