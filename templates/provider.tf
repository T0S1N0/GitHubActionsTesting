# Configure the Azure Provider
# provider.tf
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0.1"
    }
  }

  required_version = ">= 1.0.0"
}

provider "azurerm" {
  features {}
  client_id       = var.client_id       # Environment variable ARM_CLIENT_ID
  client_secret   = var.client_secret   # Environment variable ARM_CLIENT_SECRET
  subscription_id = var.subscription_id # Environment variable ARM_SUBSCRIPTION_ID
  tenant_id       = var.tenant_id       # Environment variable ARM_TENANT_ID
}



terraform {
  backend "azurerm" {
    resource_group_name  = "rg-terraform-github-actions-state"
    storage_account_name = "terraformgithubactions01 "
    container_name       = "tfstates"
    key                  = "terraform-ghactions.tfstate"
  }
}