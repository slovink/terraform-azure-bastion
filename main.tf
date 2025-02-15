module "labels" {
  source      = "git::git@github.com:slovink/terraform-azure-labels.git?ref=1.0.0"
  name        = var.name
  environment = var.environment
  managedby   = var.managedby
  label_order = var.label_order
  repository  = var.repository
}


#---------------------------------------------
# Public IP for Azure Bastion Service
#---------------------------------------------
resource "azurerm_public_ip" "pip" {
  count                = var.enabled ? 1 : 0
  name                 = format("%s-bastion-ip", module.labels.id)
  location             = var.location
  resource_group_name  = var.resource_group_name
  allocation_method    = var.public_ip_allocation_method
  sku                  = var.public_ip_sku
  ddos_protection_mode = var.ddos_protection_mode
  tags                 = module.labels.tags
}


#---------------------------------------------
# Azure Bastion Service host
#---------------------------------------------
resource "azurerm_bastion_host" "main" {
  count = var.enabled ? 1 : 0

  name                   = format("%s-bastion", module.labels.id)
  location               = var.location
  resource_group_name    = var.resource_group_name
  copy_paste_enabled     = var.enable_copy_paste
  file_copy_enabled      = var.bastion_host_sku == "Standard" ? var.enable_file_copy : null
  sku                    = var.bastion_host_sku
  ip_connect_enabled     = var.enable_ip_connect
  scale_units            = var.bastion_host_sku == "Standard" ? var.scale_units : 2
  shareable_link_enabled = var.bastion_host_sku == "Standard" ? var.enable_shareable_link : null
  tunneling_enabled      = var.bastion_host_sku == "Standard" ? var.enable_tunneling : null
  tags                   = module.labels.tags


  ip_configuration {
    name                 = format("%s-network", module.labels.id)
    subnet_id            = var.subnet_id
    public_ip_address_id = join("", azurerm_public_ip.pip[*].id)
  }
}
