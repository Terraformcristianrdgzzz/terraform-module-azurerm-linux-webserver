# Basic Linux web server example

This example calls the web server module from the local repository path. It requires an **existing** resource group and subnet. The module needs an SSH public key for Linux administrator login; its network security group keeps SSH ingress closed unless a trusted source CIDR is configured.

Copy `terraform.tfvars.example` to `terraform.tfvars`, replace the sample subnet ID and public key with values for your environment, then run:

```powershell
terraform init
terraform fmt -check
terraform validate
terraform plan
```

Review the plan and VM cost before applying. The VM size is fixed to `Standard_D2s_v7`; check its availability in the selected region.
