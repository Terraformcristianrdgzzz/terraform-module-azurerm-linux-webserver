output "vm_id" {
  description = "ID of the Linux virtual machine."
  value       = azurerm_linux_virtual_machine.webserver.id
}

output "vm_name" {
  description = "Name of the Linux virtual machine."
  value       = azurerm_linux_virtual_machine.webserver.name
}

output "public_ip_address" {
  description = "Public IPv4 address of the web server."
  value       = azurerm_public_ip.webserver.ip_address
}

output "website_url" {
  description = "HTTP URL for the Apache welcome page."
  value       = "http://${azurerm_public_ip.webserver.ip_address}"
}

output "network_security_group_id" {
  description = "ID of the network security group attached to the VM NIC."
  value       = azurerm_network_security_group.webserver.id
}

output "private_ip_address" {
  description = "Private IP address assigned to the VM NIC."
  value       = azurerm_network_interface.webserver.private_ip_address
}
