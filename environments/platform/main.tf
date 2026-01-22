terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

provider "azurerm" {
  features {}

  subscription_id = "4d49ff46-bb93-4fb0-bbe6-65d1943834ea"
  tenant_id       = "218087c8-6119-476d-9d79-6b5016c08a53"
}

# Management group defined directly here (no module)
resource "azurerm_management_group" "platform" {
  display_name = "Platform"
  name         = "platform"
}

module "policy" {
  source              = "../../modules/policy"
  allowed_locations   = ["uksouth", "ukwest"]
  management_group_id = azurerm_management_group.platform.id
}

module "monitoring" {
  source              = "../../modules/monitoring_module"
  location            = "uksouth"
  resource_group_name = azurerm_resource_group.monitoring.name
  target_resource_id  = azurerm_management_group.platform.id

  depends_on = [
    azurerm_resource_group.monitoring
  ]
}


module "networking" {
  source              = "../../modules/networking"
  location            = "uksouth"
  resource_group_name = "platform-networking-rg"
}
resource "azurerm_resource_group" "monitoring" {
  name     = "platform-monitoring-rg"
  location = "uksouth"
}
module "rbac_reader" {
  source              = "../../modules/rbac"
  scope               = azurerm_management_group.platform.id
  role_definition_name = "Reader"
  principal_id        = var.reader_principal_id
}

module "rbac_contributor" {
  source              = "../../modules/rbac"
  scope               = azurerm_management_group.platform.id
  role_definition_name = "Contributor"
  principal_id        = var.contributor_principal_id
}
