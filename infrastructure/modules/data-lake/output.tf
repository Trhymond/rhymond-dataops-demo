output "id" {
  description = "The id of the newly created storage account"
  value       = azurerm_storage_account.storage.id
}

output "name" {
  description = "The name of the newly created storage account"
  value       = azurerm_storage_account.storage.name
}

output "filesystems" {
  description = "The id of the Data Lake File System"
  value       = azurerm_storage_data_lake_gen2_filesystem.data_lake_files
}


