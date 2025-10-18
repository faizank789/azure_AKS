data "terraform_remote_state" "network" {
  backend = "azurerm"
  config = {
    resource_group_name  = "tfstate"
    storage_account_name = "apnamartiac"
    container_name       = "tfstate"
    key                  = "env/prod/network.tfstate"
  }
}
terraform {
  backend "azurerm" {
    resource_group_name  = "tfstate"
    storage_account_name = "apnamartiac"
    container_name       = "tfstate"
    key                  = "env/prod/aks.tfstate"
  }
}
