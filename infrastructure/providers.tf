terraform {
  required_version = ">= 0.15"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.46.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "=3.1.0"
    }
  }

  backend "azurerm" {
    resource_group_name  = "dev-storage-resource-group"
    storage_account_name = "devazurestorageaccount"
    container_name       = "devtfstate"
    key                  = "azureapi.dev.terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
}

provider "null" {}
