terraform {
  backend "azurerm" {
    resource_group_name  = "REPLACE_ME"
    storage_account_name = "REPLACE_ME"
    container_name       = "tfstate"
    key                  = "platform.tfstate"
  }
}
