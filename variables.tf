variable "common_tags" {
  description = "Common tags to be applied to all resources"
  type        = map(string)
  default = {
    CreatedBy = "Terraform"
  }
}

variable "path_to_license_file" {
  description = "Path to the license file"
  type        = string
}

variable "ansible_user" {
  description = "The user to be used for Ansible"
  type        = string
}

variable "postgres_password" {
  description = "The password to be used for PostgreSQL"
  type        = string
}

variable "kubernetes_subnet_cidr" {
  description = "CIDR range for Kubernetes subnet"
  type        = string
  # This should match your AKS subnet CIDR
  default     = "10.0.2.0/24"  # Adjust based on your k8s subnet
}
