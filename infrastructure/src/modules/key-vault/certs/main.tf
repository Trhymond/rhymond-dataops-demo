data "azurerm_client_config" "current" {}

data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

resource "azurerm_key_vault_certificate" "imported_cert" {
  name         = var.certificate.name
  key_vault_id = var.keyvault_id

  lifecycle {
    ignore_changes = all
  }

  certificate {
    contents = filebase64(var.certificate.cert_file)
    password = var.certificate.password
  }
}



