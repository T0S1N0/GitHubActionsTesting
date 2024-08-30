# Configure the Azure Provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.57.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.39.0"
    }
    azapi = {
      source  = "Azure/azapi"
      version = "~> 1.6.0"
    }
  }
}

provider "azurerm" {
  subscription_id = "__subscription_id__"
  client_id       = "__sp_client_id__"
  client_secret   = "__sp_client_secret__"
  tenant_id       = "__tenant_id__"
  features {}
}

provider "azuread" {
  tenant_id     = "__tenant_id__"
  client_id     = "__sp_client_id__"
  client_secret = "__sp_client_secret__"
}

provider "azapi" {
  subscription_id = "__subscription_id__"
  tenant_id       = "__tenant_id__"
  client_id       = "__sp_client_id__"
  client_secret   = "__sp_client_secret__"
}

terraform {
  backend "azurerm" {
    resource_group_name  = "__rg_terraform_backend_name__"
    storage_account_name = "__st_terraform_backend_name__"
    container_name       = "tfstates"
    key                  = "tf-__project__-__environment__.tfstate"
    access_key           = "__st_terraform_backend_key__"
  }
}

provider "azurerm" {
  alias           = "__alias_name__"
  subscription_id = "__alias_subscription_id__"
  features {}
}

provider "azurerm" {
  alias           = "dwi"
  subscription_id = "__dwi_subscription_id__"
  features {}
}