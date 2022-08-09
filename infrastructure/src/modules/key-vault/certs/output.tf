output "cert_id" {
  description = "The id of the newly created KeyVault certificate"
  value       = azurerm_key_vault_certificate.imported_cert.id
}

output "cert_secretid" {
  description = "The secret id of the newly created KeyVault certificate"
  value       = azurerm_key_vault_certificate.imported_cert.secret_id
}


