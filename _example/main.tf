provider "azurerm" {
  features {}
}

module "resource_group" {
  source = "git::git@github.com:slovink/terraform-azure-resource-group.git?ref=1.0.0"

  name        = "app"
  environment = "test"
  label_order = ["name", "environment"]
  location    = "Canada Central"
}

module "vnet" {
  source              = "git::git@github.com:slovink/terraform-azure-vnet.git?ref=1.0.0"
  name                = "app"
  environment         = "test"
  label_order         = ["name", "environment"]
  resource_group_name = module.resource_group.resource_group_name
  location            = module.resource_group.resource_group_location
  address_space       = "10.0.0.0/16"
  enable_ddos_pp      = false
}

module "name_specific_subnet" {
  source               = "git::git@github.com:slovink/terraform-azure-subnet.git?ref=1.0.0"
  name                 = "app"
  environment          = "test"
  label_order          = ["name", "environment"]
  resource_group_name  = module.resource_group.resource_group_name
  location             = module.resource_group.resource_group_location
  virtual_network_name = module.vnet.name

  #subnet
  specific_name_subnet  = true
  specific_subnet_names = "AzureBastionSubnet"
  subnet_prefixes       = ["10.0.1.0/24"]

}

module "bastion" {
  depends_on           = [module.resource_group]
  source               = "./../"
  name                 = "app"
  environment          = "test"
  label_order          = ["name", "environment"]
  resource_group_name  = module.resource_group.resource_group_name
  location             = module.resource_group.resource_group_location
  virtual_network_name = module.vnet.name
  subnet_id            = module.name_specific_subnet.specific_subnet_id
}
