variable "resource_group_name" {
  description = "Name of the existing resource group for the web server resources."
  type        = string

  validation {
    condition     = length(trimspace(var.resource_group_name)) > 0
    error_message = "resource_group_name must not be empty."
  }
}

variable "location" {
  description = "Azure region for the web server resources."
  type        = string

  validation {
    condition     = length(trimspace(var.location)) > 0
    error_message = "location must not be empty."
  }
}

variable "vm_name" {
  description = "Name of the Linux virtual machine; also used as a prefix for related resources."
  type        = string

  validation {
    condition     = length(trimspace(var.vm_name)) > 0 && length(var.vm_name) <= 64
    error_message = "vm_name must contain between 1 and 64 characters."
  }
}

variable "admin_username" {
  description = "Linux administrator username."
  type        = string

  validation {
    condition     = length(trimspace(var.admin_username)) > 0 && !strcontains(var.admin_username, " ")
    error_message = "admin_username must not be empty or contain spaces."
  }
}

variable "admin_ssh_public_key" {
  description = "SSH public key for the VM administrator. Do not provide a private key."
  type        = string

  validation {
    condition     = length(split(" ", trimspace(var.admin_ssh_public_key))) >= 2 && contains(["ssh-ed25519", "ssh-rsa", "ecdsa-sha2-nistp256", "ecdsa-sha2-nistp384", "ecdsa-sha2-nistp521"], split(" ", trimspace(var.admin_ssh_public_key))[0])
    error_message = "admin_ssh_public_key must be an OpenSSH public key (for example, ssh-ed25519); never provide a private key."
  }
}

variable "subnet_id" {
  description = "ID of the existing subnet where the VM network interface will be attached."
  type        = string

  validation {
    condition     = can(regex("(?i)^/subscriptions/[^/]+/resourceGroups/[^/]+/providers/Microsoft\\.Network/virtualNetworks/[^/]+/subnets/[^/]+$", var.subnet_id))
    error_message = "subnet_id must be a full Azure subnet resource ID."
  }
}

variable "ssh_source_address_prefix" {
  description = "Optional trusted IPv4 CIDR allowed to SSH to the VM, such as your public IP with /32. If null, no SSH ingress rule is created."
  type        = string
  default     = null

  validation {
    condition = (
      var.ssh_source_address_prefix == null ||
      (
        can(cidrnetmask(var.ssh_source_address_prefix)) &&
        try(tonumber(split("/", var.ssh_source_address_prefix)[1]) > 0, false)
      )
    )
    error_message = "ssh_source_address_prefix must be a valid IPv4 CIDR more restrictive than 0.0.0.0/0, for example 203.0.113.10/32, or null."
  }
}

variable "os_disk_size_gb" {
  description = "Size of the Linux OS disk in GB."
  type        = number
  default     = 30

  validation {
    condition     = var.os_disk_size_gb >= 30
    error_message = "os_disk_size_gb must be at least 30 GB."
  }
}
