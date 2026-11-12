mock_provider "azurerm" {
  mock_resource "azurerm_public_ip" {
    defaults = {
      id         = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Network/publicIPAddresses/vm-test-pip"
      ip_address = "198.51.100.10"
    }
  }

  mock_resource "azurerm_network_security_group" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Network/networkSecurityGroups/vm-test-nsg"
    }
  }

  mock_resource "azurerm_network_security_rule" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Network/networkSecurityGroups/vm-test-nsg/securityRules/ssh"
    }
  }

  mock_resource "azurerm_network_interface" {
    defaults = {
      id                 = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Network/networkInterfaces/vm-test-nic"
      private_ip_address = "10.10.1.4"
    }
  }

  mock_resource "azurerm_network_interface_security_group_association" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Network/networkInterfaces/vm-test-nic"
    }
  }

  mock_resource "azurerm_linux_virtual_machine" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Compute/virtualMachines/vm-test"
    }
  }
}

variables {
  resource_group_name  = "rg-test"
  location             = "East US"
  vm_name              = "vm-test"
  admin_username       = "azureuser"
  admin_ssh_public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGYRfcekcBMIMpQre6Xi3IM2SZmBgIRqT/ihJ4DgkNwE terraform-test-only"
  subnet_id            = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Network/virtualNetworks/vnet-test/subnets/snet-test"
}

run "webserver_outputs_and_ssh_closed_by_default" {
  command = apply

  assert {
    condition     = output.vm_name == "vm-test" && output.public_ip_address == "198.51.100.10"
    error_message = "The module must return the VM name and public IP address."
  }

  assert {
    condition     = output.website_url == "http://198.51.100.10"
    error_message = "The module must construct the HTTP website URL from the public IP."
  }

  assert {
    condition     = output.private_ip_address == "10.10.1.4" && output.network_security_group_id != ""
    error_message = "The module must return its NIC private IP and NSG ID."
  }

  assert {
    condition     = length(azurerm_network_security_rule.ssh) == 0
    error_message = "SSH ingress must be disabled when no trusted CIDR is configured."
  }
}

run "allows_ssh_only_from_configured_cidr" {
  command = plan

  variables {
    ssh_source_address_prefix = "203.0.113.10/32"
  }

  assert {
    condition     = length(azurerm_network_security_rule.ssh) == 1 && azurerm_network_security_rule.ssh[0].source_address_prefix == "203.0.113.10/32"
    error_message = "When enabled, SSH must be restricted to the configured trusted CIDR."
  }
}

run "rejects_invalid_ssh_cidr" {
  command = plan

  variables {
    ssh_source_address_prefix = "not-a-cidr"
  }

  expect_failures = [var.ssh_source_address_prefix]
}

run "rejects_open_ssh_cidr" {
  command = plan

  variables {
    ssh_source_address_prefix = "0.0.0.0/0"
  }

  expect_failures = [var.ssh_source_address_prefix]
}

run "rejects_unsupported_vm_name_length" {
  command = plan

  variables {
    vm_name = "this-vm-name-is-deliberately-longer-than-sixty-four-characters-to-test-validation"
  }

  expect_failures = [var.vm_name]
}

run "rejects_invalid_subnet_id" {
  command = plan

  variables {
    subnet_id = "not-an-azure-resource-id"
  }

  expect_failures = [var.subnet_id]
}

run "rejects_too_small_os_disk" {
  command = plan

  variables {
    os_disk_size_gb = 29
  }

  expect_failures = [var.os_disk_size_gb]
}

run "rejects_invalid_ssh_public_key_type" {
  command = plan

  variables {
    admin_ssh_public_key = "private-key-material"
  }

  expect_failures = [var.admin_ssh_public_key]
}
