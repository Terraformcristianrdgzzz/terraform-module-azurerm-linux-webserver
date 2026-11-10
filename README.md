# terraform-module-azurerm-linux-webserver

A reusable Terraform module that creates an Ubuntu Linux VM in an existing Azure subnet, assigns it a public IP address, attaches an NSG, and installs Apache with a simple "Hello from Terraform!" page.

The VM size is fixed to `Standard_D2s_v7`. Confirm its availability and cost in the target Azure region and subscription before deployment.

The module does not create a resource group, virtual network, or subnet, and it does not configure a Terraform backend or Azure RBAC roles. The calling configuration is responsible for those concerns.

## Architecture

```text
Existing Resource Group and Subnet
├── Standard Public IP
├── Network Security Group
│   ├── HTTP (TCP/80) from the Internet
│   └── Optional SSH (TCP/22) from one trusted IPv4 CIDR
├── Network Interface
└── Ubuntu Linux VM
    └── Apache serving "Hello from Terraform!"
```

SSH is not allowed unless `ssh_source_address_prefix` is set. Do not expose SSH to the whole Internet.

## Requirements

| Name | Version |
| --- | --- |
| Terraform | >= 1.5.0 |
| AzureRM provider | >= 4.0.0, < 5.0.0 |

The calling root configuration must configure the AzureRM provider, authentication, and backend. The subnet must already exist in the specified resource group.

## Usage

This module is intended to be composed with the network module. The `v0.1.0` references below are examples; create and verify those tags before using them.

```hcl
module "network" {
  source = "git::https://github.com/Terraformcristianrdgzzz/terraform-module-azurerm-network.git?ref=v0.1.0"

  resource_group_name = "rg-terraformdeployments-stage"
  location            = "East US"
  vnet_name           = "vnet-stage"
  vnet_address_space  = ["10.10.0.0/16"]
  subnet_name         = "snet-web"
  subnet_prefixes     = ["10.10.1.0/24"]
}

module "webserver" {
  source = "git::https://github.com/Terraformcristianrdgzzz/terraform-module-azurerm-linux-webserver.git?ref=v0.1.0"

  resource_group_name  = "rg-terraformdeployments-stage"
  location             = "East US"
  vm_name              = "vm-web-stage"
  admin_username       = "azureuser"
  admin_ssh_public_key = file("C:/Users/YOUR_USER/.ssh/id_rsa.pub")
  subnet_id            = module.network.subnet_id

  # Optional: allow SSH only from your trusted public IP.
  # ssh_source_address_prefix = "203.0.113.10/32"
}

output "website_url" {
  value = module.webserver.website_url
}
```

Replace the example username, SSH public key path, address ranges, names, and VM size with values appropriate for your environment. The module needs only the public key; never provide or commit a private key.

## Inputs

| Name | Description | Type | Required |
| --- | --- | --- | --- |
| `resource_group_name` | Name of the existing resource group for the web server resources. | `string` | yes |
| `location` | Azure region for the resources. | `string` | yes |
| `vm_name` | VM name and prefix for related resource names. | `string` | yes |
| `admin_username` | Linux administrator username. | `string` | yes |
| `admin_ssh_public_key` | SSH public key for the VM administrator. | `string` | yes |
| `subnet_id` | ID of the existing subnet for the VM network interface. | `string` | yes |
| `ssh_source_address_prefix` | Optional trusted IPv4 CIDR allowed to SSH, for example `203.0.113.10/32`. If `null`, no SSH ingress rule is created. | `string` | no; defaults to `null` |
| `os_disk_size_gb` | OS disk size in GB; must be at least 30 GB. | `number` | no; defaults to `30` |

## Outputs

| Name | Description |
| --- | --- |
| `vm_id` | ID of the Linux virtual machine. |
| `vm_name` | Name of the Linux virtual machine. |
| `public_ip_address` | Public IPv4 address assigned to the VM. |
| `website_url` | HTTP URL for the Apache page. |
| `network_security_group_id` | ID of the NSG attached to the NIC. |
| `private_ip_address` | Private IP address assigned to the NIC. |

After deployment and cloud-init completion, open the `website_url` output in a browser. Apache installation happens during VM initialization and may take a few minutes after Terraform finishes.

## Cost and security considerations

- A running VM, OS disk, and Standard public IPv4 address may incur charges. A VM size being listed as eligible for a free offer does not guarantee that the complete deployment is free. Check the current offer and Azure pricing estimate before applying.
- HTTP is open to the Internet for this demonstration. Do not use this sample NSG as a production web security design without review.
- SSH is closed by default. If needed, allow only a trusted IPv4 CIDR using `ssh_source_address_prefix`.
- The caller's identity needs appropriate compute permissions and network permissions on the target resource group. This module does not create RBAC assignments.
- Terraform state and plans may contain sensitive information. Protect the backend and do not commit state or plan files.

## Versioning

Use semantic version tags and reference a specific tag from consumers instead of depending on the moving `main` branch.

## License

MIT
