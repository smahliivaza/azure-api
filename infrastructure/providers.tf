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
    // //    //            use_msi              = true
    // //    //        subscription_id      = "00000000-0000-0000-0000-000000000000"
    // //    //        tenant_id            = "00000000-0000-0000-0000-000000000000"
  }
}

provider "azurerm" {
  features {}
}

provider "null" {}
