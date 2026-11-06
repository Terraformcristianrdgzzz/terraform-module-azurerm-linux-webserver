# terraform-azurerm-linux-webserver

Terraform module to deploy a simple Linux web server in Microsoft Azure.

The module creates:

- Linux Virtual Machine
- Public IP Address
- Network Interface
- Network Security Group (NSG)
- Security Rules
- Apache Web Server

This module is intended for learning, testing and reusable deployments across multiple environments such as **stage** and **prod**.

## Architecture

```text
Resource Group
├── Public IP
├── Network Security Group
├── Network Interface
└── Linux Virtual Machine
    └── Apache Web Server
```

## Requirements

| Name | Version |
|--------|---------|
| Terraform | >= 1.0.0 |
| AzureRM Provider | ~> 3.0 |

## Usage

```hcl
module "webserver" {
  source = "git::https://github.com/cristianrdgzzz/terraform-azurerm-linux-webserver.git?ref=v0.1.0"

  resource_group_name = "rg-terraformdeployments-stage"
  location            = "westeurope"

  vm_name             = "vm-web-stage"
  vm_size             = "Standard_B1s"

  admin_username      = "azureuser"
  public_key          = file("~/.ssh/id_rsa.pub")

  subnet_id           = module.network.subnet_id
}
```

## Inputs

| Name | Description | Type | Required |
|--------|------------|------|---------|
| resource_group_name | Resource Group name | string | Yes |
| location | Azure region | string | Yes |
| vm_name | Virtual Machine name | string | Yes |
| vm_size | Azure VM size | string | Yes |
| admin_username | Linux administrator username | string | Yes |
| public_key | SSH public key | string | Yes |
| subnet_id | Target subnet ID | string | Yes |

## Outputs

| Name | Description |
|--------|------------|
| vm_id | Virtual Machine ID |
| vm_name | Virtual Machine name |
| public_ip | Public IP Address |
| nsg_id | Network Security Group ID |

## Example

```hcl
module "webserver" {
  source = "git::https://github.com/cristianrdgzzz/terraform-azurerm-linux-webserver.git?ref=v0.1.0"

  resource_group_name = "rg-terraformdeployments-stage"
  location            = "westeurope"

  vm_name        = "web-stage"
  vm_size        = "Standard_B1s"

  admin_username = "azureuser"
  public_key     = file("~/.ssh/id_rsa.pub")

  subnet_id      = module.network.subnet_id
}
```

## What Gets Installed

The VM automatically installs:

- Apache HTTP Server
- Sample index.html page

After deployment, browse to:

```text
http://<PUBLIC_IP>
```

You should see a simple welcome page served by Apache.

## Security Notes

- SSH access should be restricted to trusted IP addresses whenever possible.
- Avoid opening port 22 to the entire Internet.
- Use SSH keys instead of passwords.
- Follow the principle of least privilege for Azure RBAC permissions.
- Review NSG rules before deploying to production environments.

## Versioning

This module follows Semantic Versioning.

Examples:

- v0.1.0 → Initial release
- v0.2.0 → New features
- v1.0.0 → Stable production release

Always reference a specific version tag:

```hcl
source = "git::https://github.com/cristianrdgzzz/terraform-azurerm-linux-webserver.git?ref=v0.1.0"
```

## License

MIT License
