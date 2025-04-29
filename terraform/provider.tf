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
  client_id       = var.client_id       # Environment secret ARM_CLIENT_ID
  client_secret   = var.client_secret   # Environment secret ARM_CLIENT_SECRET
  subscription_id = var.subscription_id # Environment secret ARM_SUBSCRIPTION_ID
  tenant_id       = var.tenant_id       # Environment secret ARM_TENANT_ID
}

terraform {
  backend "azurerm" {
    resource_group_name  = "rg-config-test-es-001"
    storage_account_name = "stconfigtestes001"
    container_name       = "tfstates"
    key                  = "terraform-ghactions.tfstate"
  }
}