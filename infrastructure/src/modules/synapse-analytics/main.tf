data "azurerm_client_config" "current" {}

data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

locals {
  synapse_workspace_name = replace(lower("${var.project_name}-${var.environment_name}-${var.location_short_name}-syn-ws"), "-", "")
  synapse_pool_name      = replace(lower("${var.project_name}-${var.environment_name}-${var.location_short_name}-syn-sqlpool"), "-", "")
  current_time           = timestamp()
  expiration_hours       = var.secret_expiration_days * 24
  secret_expiration_date = formatdate("YYYY-MM-DD", timeadd(local.current_time, "${local.expiration_hours}h"))
}

resource "random_password" "password" {
  count = 3

  length           = 12
  special          = true
  override_special = "@$#^()"
  min_lower        = 1
  min_upper        = 1
  min_numeric      = 1
}

resource "azurerm_key_vault_key" "customer_key" {
  #checkov:skip=CKV_AZURE_112: "Ensure that key vault key is backed by HSM"
  name            = "${local.synapse_workspace_name}-key"
  key_vault_id    = var.keyvault_id
  key_type        = "RSA"
  key_size        = 2048
  key_opts        = ["decrypt", "encrypt", "sign", "unwrapKey", "verify", "wrapKey"]
  expiration_date = local.secret_expiration_date
}

resource "azurerm_synapse_workspace" "synapse_workspace" {
  name                = local.synapse_workspace_name
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  tags = merge(var.tags, {
    "criticality" = "High"
  })

  storage_data_lake_gen2_filesystem_id = var.datalake_filesystem_id
  sql_administrator_login              = var.sqlpool_admin_user_name
  sql_administrator_login_password     = random_password.password[0].result

  customer_managed_key {
    key_versionless_id = azurerm_key_vault_key.customer_key.versionless_id
    key_name           = "enckey"
  }

  identity {
    type = "SystemAssigned"
  }

  data_exfiltration_protection_enabled = true
  public_network_access_enabled        = false
  managed_virtual_network_enabled      = true
  sql_identity_control_enabled         = true
  managed_resource_group_name          = "${local.synapse_workspace_name}-managed-rg"

  sql_aad_admin {
    login     = "synapse-sql-admin"
    object_id = var.synapse_admin_object_id
    tenant_id = data.azurerm_client_config.current.tenant_id
  }

  depends_on = [
    azurerm_key_vault_key.customer_key,
    random_password.password
  ]
}

resource "azurerm_key_vault_access_policy" "workspace_policy" {
  key_vault_id = var.keyvault_id
  tenant_id    = azurerm_synapse_workspace.synapse_workspace.identity[0].tenant_id
  object_id    = azurerm_synapse_workspace.synapse_workspace.identity[0].principal_id

  key_permissions = [
    "Get", "WrapKey", "UnwrapKey"
  ]

  depends_on = [
    azurerm_synapse_workspace.synapse_workspace
  ]
}

resource "azurerm_synapse_workspace_key" "workspace_key" {
  customer_managed_key_versionless_id = azurerm_key_vault_key.customer_key.versionless_id
  synapse_workspace_id                = azurerm_synapse_workspace.synapse_workspace.id
  active                              = true
  customer_managed_key_name           = "enckey"

  depends_on = [
    azurerm_key_vault_key.customer_key,
    azurerm_synapse_workspace.synapse_workspace
  ]
}


resource "azurerm_synapse_sql_pool" "synapse_pool" {
  name                 = local.synapse_pool_name
  synapse_workspace_id = azurerm_synapse_workspace.synapse_workspace.id
  sku_name             = var.sqlpool_sku_name
  create_mode          = "Default"
  data_encrypted       = true

  tags = merge(var.tags, {
    "criticality" = "High"
  })

  depends_on = [
    azurerm_synapse_workspace.synapse_workspace
  ]
}

resource "azurerm_key_vault_secret" "admin_pswd_secret" {
  name            = "synapse-admin-password"
  value           = random_password.password[0].result
  key_vault_id    = var.keyvault_id
  expiration_date = local.secret_expiration_date
  content_type    = "text/plain"

  depends_on = [
    random_password.password
  ]
}

resource "azurerm_synapse_workspace_aad_admin" "example" {
  synapse_workspace_id = azurerm_synapse_workspace.synapse_workspace.id
  login                = "syanpse-aad-admin"
  object_id            = var.synapse_admin_object_id
  tenant_id            = data.azurerm_client_config.current.tenant_id

  depends_on = [
    azurerm_synapse_workspace.synapse_workspace
  ]
}

# resource "azurerm_synapse_firewall_rule" "synapse_firewall_rule" {
#   for_each             = var.firewall_rules
#   name                 = each.value.name
#   synapse_workspace_id = azurerm_synapse_workspace.synapse_workspace.id
#   start_ip_address     = each.value.start_ip
#   end_ip_address       = each.value.end_ip

#   depends_on = [
#     azurerm_synapse_workspace.synapse_workspace
#   ]
# }
