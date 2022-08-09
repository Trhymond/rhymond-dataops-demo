output "cert_id" {
  description = "The id of the newly created KeyVault certificate"
  value       = azurerm_key_vault_certificate.self_signed.id
}

output "secret_id" {
  description = "The id of the newly created KeyVault certificate secret id"
  value       = azurerm_key_vault_certificate.self_signed.secret_id
}


