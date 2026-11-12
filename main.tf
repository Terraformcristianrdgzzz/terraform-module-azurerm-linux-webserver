resource "azurerm_public_ip" "webserver" {
  name                = "${var.vm_name}-pip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"

  lifecycle {
    postcondition {
      condition     = self.sku == "Standard" && self.ip_address != ""
      error_message = "Azure must assign a public IPv4 address using the Standard SKU."
    }
  }
}

resource "azurerm_network_security_group" "webserver" {
  name                = "${var.vm_name}-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name

  security_rule {
    name                       = "Allow-HTTP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }

  lifecycle {
    postcondition {
      condition = anytrue([
        for rule in self.security_rule :
        rule.name == "Allow-HTTP" &&
        rule.direction == "Inbound" &&
        rule.access == "Allow" &&
        rule.protocol == "Tcp" &&
        rule.destination_port_range == "80" &&
        rule.source_address_prefix == "Internet"
      ])
      error_message = "The network security group must allow inbound HTTP from the Internet."
    }
  }
}

resource "azurerm_network_security_rule" "ssh" {
  count = var.ssh_source_address_prefix == null ? 0 : 1

  name                        = "Allow-SSH-From-Trusted-Source"
  priority                    = 110
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = var.ssh_source_address_prefix
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.webserver.name

  lifecycle {
    postcondition {
      condition     = self.source_address_prefix == var.ssh_source_address_prefix && self.destination_port_range == "22"
      error_message = "The SSH rule must only allow port 22 from the explicitly configured trusted CIDR."
    }
  }
}

resource "azurerm_network_interface" "webserver" {
  name                = "${var.vm_name}-nic"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.webserver.id
  }

  lifecycle {
    postcondition {
      condition     = self.private_ip_address != ""
      error_message = "Azure must assign a private IP address to the network interface."
    }
  }
}

resource "azurerm_network_interface_security_group_association" "webserver" {
  network_interface_id      = azurerm_network_interface.webserver.id
  network_security_group_id = azurerm_network_security_group.webserver.id
}

resource "azurerm_linux_virtual_machine" "webserver" {
  name                = var.vm_name
  computer_name       = substr(var.vm_name, 0, 64)
  location            = var.location
  resource_group_name = var.resource_group_name
  size                = "Standard_D2s_v7"

  admin_username                  = var.admin_username
  disable_password_authentication = true

  network_interface_ids = [
    azurerm_network_interface.webserver.id
  ]

  admin_ssh_key {
    username   = var.admin_username
    public_key = var.admin_ssh_public_key
  }

  lifecycle {
    precondition {
      condition = (
        azurerm_network_interface_security_group_association.webserver.network_interface_id == azurerm_network_interface.webserver.id &&
        azurerm_network_interface_security_group_association.webserver.network_security_group_id == azurerm_network_security_group.webserver.id
      )
      error_message = "The VM's network interface must be associated with the module's network security group."
    }

    postcondition {
      condition     = self.size == "Standard_D2s_v7" && self.disable_password_authentication
      error_message = "The VM must use Standard_D2s_v7 and password authentication must remain disabled."
    }
  }

  os_disk {
    name                 = "${var.vm_name}-osdisk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    disk_size_gb         = var.os_disk_size_gb
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  custom_data = filebase64("${path.module}/cloud-init.yaml")

  depends_on = [
    azurerm_network_interface_security_group_association.webserver
  ]
}
