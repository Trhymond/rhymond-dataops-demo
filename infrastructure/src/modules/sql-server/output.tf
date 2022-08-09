output "id" {
  description = "The Microsoft SQL Server ID"
  value       = azurerm_mssql_server.sql_server.id
}

output "name" {
  description = "The fully qualified domain name of the Azure SQL Server (e.g. myServerName.database.windows.net)"
  value       = azurerm_mssql_server.sql_server.fully_qualified_domain_name
}

output "databases" {
  description = "The  new created sql databses"
  value       = azurerm_mssql_database.sql_database
}


