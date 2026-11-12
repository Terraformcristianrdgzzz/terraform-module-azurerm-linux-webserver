provider "azurerm" {
  features {}
}

module "webserver" {
  source = "../../"

  resource_group_name       = var.resource_group_name
  location                  = var.location
  vm_name                   = var.vm_name
  admin_username            = var.admin_username
  admin_ssh_public_key      = var.admin_ssh_public_key
  subnet_id                 = var.subnet_id
  ssh_source_address_prefix = var.ssh_source_address_prefix
  os_disk_size_gb           = var.os_disk_size_gb
}
