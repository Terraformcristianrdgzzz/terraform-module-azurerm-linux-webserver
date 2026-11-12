variable "resource_group_name" {
  description = "Name of an existing resource group."
  type        = string
}

variable "location" {
  description = "Azure region for the web server."
  type        = string
}

variable "vm_name" {
  description = "Linux VM name."
  type        = string
}

variable "admin_username" {
  description = "Linux administrator username."
  type        = string
}

variable "admin_ssh_public_key" {
  description = "SSH public key for the VM administrator, never a private key."
  type        = string
}

variable "subnet_id" {
  description = "ID of an existing subnet."
  type        = string
}

variable "ssh_source_address_prefix" {
  description = "Optional trusted IPv4 CIDR allowed to SSH. Null disables SSH ingress."
  type        = string
  default     = null
}

variable "os_disk_size_gb" {
  description = "Linux OS disk size in GB."
  type        = number
  default     = 30
}
