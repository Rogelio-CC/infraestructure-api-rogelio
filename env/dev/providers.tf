terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }

  /*  backend "azurerm" {
    resource_group_name = "RG-roger"
    storage_account_name = "ozielaccount"
    container_name = "712tfstate"
    key = "terraform.tfstate"
  } */
}

provider "azurerm" {
  features {

  }
}