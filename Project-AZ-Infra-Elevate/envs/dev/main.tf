provider "azurerm" {
  features {}
}

locals {
  rg_types = ["network", "compute", "shared", "security", "storage"]
}

module "resource_groups" {
  source      = "../../modules/resource_group"
  for_each    = toset(local.rg_types)
  project     = "azinfra"
  environment = "dev"
  type        = each.value
  location    = "eastus"
}

output "resource_group_names" {
  value = { for k, rg in module.resource_groups : k => rg.resource_group_name }
}

output "resource_group_locations" {
  value = { for k, rg in module.resource_groups : k => rg.resource_group_location }
}

# Output the public IPs of the VMs in the public subnet
output "public_vm_public_ips" {
  description = "Public IPs of the VMs in the public subnet."
  value       = module.vm.public_vm_ips
}

# Create NSG for public subnet
module "public_nsg" {
  source              = "../../modules/network/nsg"
  resource_group_name = module.resource_groups["network"].resource_group_name
  location            = module.resource_groups["network"].resource_group_location
  nsg_name            = "azinfra-dev-public-nsg"
  security_rules = [
    {
      name                       = "SSH"
      priority                   = 1001
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "22"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    },
    {
      name                       = "HTTP-Access"
      priority                   = 1002
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "80"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    }
  ]
}

# Associate NSG with public subnet
resource "azurerm_subnet_network_security_group_association" "public" {
  subnet_id                 = module.dev_vnet.public_subnet_id
  network_security_group_id = module.public_nsg.nsg_id
}


# Create VNet for dev environment
module "dev_vnet" {
  source                  = "../../modules/network/vnet"
  vnet_name               = "azinfra-dev-vnet"
  address_space           = ["10.16.0.0/12"]
  location                = module.resource_groups["network"].resource_group_location
  resource_group_name     = module.resource_groups["network"].resource_group_name
  public_subnet_name      = "azinfra-dev-public-subnet"
  public_subnet_prefixes  = ["10.16.1.0/24"]
  private_subnet_name     = "azinfra-dev-private-subnet"
  private_subnet_prefixes = ["10.16.2.0/24"]
}

module "vm" {
  source              = "../../modules/compute/vm"
  public_vm_names     = ["ansible-managed-node-1", "ansible-managed-node-2"]
#   public_vm_names     = ["ansible-managed-node-1"]
#   private_vm_names    = ["private-vm-1"]
  public_subnet_id    = module.dev_vnet.public_subnet_id
  private_subnet_id   = module.dev_vnet.private_subnet_id
  resource_group_name = module.resource_groups["compute"].resource_group_name
  location            = module.resource_groups["compute"].resource_group_location
  admin_username      = "azureuser"
  admin_ssh_key       = file("${path.module}/id_rsa_azure_vm.pub")
  admin_private_key   = "${path.module}/id_rsa_azure_vm"
}
