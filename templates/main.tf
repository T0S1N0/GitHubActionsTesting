# Create a resource group
resource "azurerm_resource_group" "example" {
  name     = "example-resources"
  location = "East US"
}

# Create a storage account
resource "azurerm_storage_account" "example" {
  name                     = "examplestoracc"
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# Output the storage account name
output "storage_account_name" {
  value = azurerm_storage_account.example.name
}
