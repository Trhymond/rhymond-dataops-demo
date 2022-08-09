output "id" {
  description = "The id of the newly created storage account"
  value       = azurerm_storage_account.storage.id
}

output "name" {
  description = "The name of the newly created storage account"
  value       = azurerm_storage_account.storage.name
}

output "primary_key" {
  description = "The primary key of the newly created storage account"
  value       = azurerm_storage_account.storage.primary_access_key
}

output "secondary_key" {
  description = "The secondary key of the newly created storage account"
  value       = azurerm_storage_account.storage.secondary_access_key
}


