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
