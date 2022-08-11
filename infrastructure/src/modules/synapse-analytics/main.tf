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

  identity {
    type = "SystemAssigned"
  }

  data_exfiltration_protection_enabled = true
  public_network_access_enabled        = false
  managed_virtual_network_enabled      = true
  sql_identity_control_enabled         = true
  managed_resource_group_name          = "${synapse_workspace_name}-managed-rg"

  # sql_aad_admin {
  #   login     = ""
  #   object_id = ""
  #   tenant_id = ""
  # }
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
