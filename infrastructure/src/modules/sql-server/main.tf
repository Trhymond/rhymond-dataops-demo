data "azurerm_client_config" "current" {}

data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}
data "azurerm_storage_account" "storage" {
  name                = var.storage_account_name
  resource_group_name = var.resource_group_name
}

locals {
  sql_server_name     = lower("${var.project_name}-${var.environment_name}-${var.location_short_name}-sql")
  diag_log_categories = ["SQLInsights", "AutomaticTuning", "QueryStoreRuntimeStatistics", "QueryStoreWaitStatistics", "Errors", "DatabaseWaitStatistics", "Timeouts", "Blocks", "Deadlocks", "DevOpsOperationsAudit", "SQLSecurityAuditEvents"]

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

resource "azurerm_mssql_server" "sql_server" {
  #checkov:skip=CKV_AZURE_24: "Ensure that 'Auditing' Retention is 'greater than 90 days' for SQL servers"
  #checkov:skip=CKV_AZURE_23: "Ensure that 'Auditing' is set to 'On' for SQL servers"
  name                = local.sql_server_name
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  tags = merge(var.tags, {
    "criticality" = "High"
  })

  version                       = "12.0"
  administrator_login           = var.sql_admin_username
  administrator_login_password  = random_password.password[0].result
  minimum_tls_version           = "1.2"
  public_network_access_enabled = false

  dynamic "azuread_administrator" {
    for_each = var.sql_ad_admin != null ? [1] : []
    content {
      login_username = var.sql_ad_admin.login_username
      object_id      = var.sql_ad_admin.object_id
    }
  }

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_mssql_elasticpool" "sql_pool" {
  count = var.sql_pool_name != null ? 1 : 0

  name                = var.sql_pool_name
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  server_name         = azurerm_sql_server.sql_server.name
  license_type        = "LicenseIncluded"
  max_size_gb         = var.sql_pool_size_gb
  sku                 = var.sql_pool_sku

  per_database_settings {
    min_capacity = var.sql_pool_db_min_capacity
    max_capacity = var.sql_pool_db_max_capacity
  }
}


resource "azurerm_mssql_database" "sql_database" {
  for_each = var.sql_databases
  name     = each.value.sql_database_name
  tags     = merge(var.tags, each.value.tags)

  server_id = azurerm_mssql_server.sql_server.id
  collation = "SQL_Latin1_General_CP1_CI_AS"

  max_size_gb = each.value.max_size_gb
  sku_name    = each.value.sku_name
  threat_detection_policy {
    state           = "Enabled"
    disabled_alerts = []
  }

  transparent_data_encryption_enabled = true
  zone_redundant                      = each.value.zone_redundant
  elastic_pool_id                     = var.sql_pool_name != null ? azurerm_mssql_elasticpool.sql_pool.id : null

  # extended_auditing_policy {
  #   storage_endpoint                        = azurerm_storage_account.example.primary_blob_endpoint
  #   storage_account_access_key              = azurerm_storage_account.example.primary_access_key
  #   storage_account_access_key_is_secondary = true
  #   retention_in_days                       = 120

  # }

  depends_on = [
    azurerm_mssql_server.sql_server
  ]
}

data "http" "my_public_ip" {
  url = "https://ifconfig.com"
  request_headers = {
    Accept = "application/json"
  }
}

locals {
  ifconfig_co_json = jsonencode(data.http.my_public_ip.body)
  firewall_rules = merge(var.sql_server_firewall_rules, {
    firwall_rule_name = "AllowAccesToDeploymentServer"
    start_ip_address  = local.ifconfig_co_json
    end_ip_address    = local.ifconfig_co_json
  })
}

resource "azurerm_mssql_firewall_rule" "sql_server_firewall_rules" {
  for_each         = local.firewall_rules
  name             = each.value.firwall_rule_name
  start_ip_address = each.value.start_ip_address
  end_ip_address   = each.value.end_ip_address
  server_id        = azurerm_mssql_server.sql_server.id

  depends_on = [
    azurerm_mssql_server.sql_server,
    data.http.my_public_ip
  ]
}

# Allow access to Azure Services
resource "azurerm_mssql_firewall_rule" "sql_server_firewall_rules_azure_services" {
  name             = "AllowAllWindowsAzureIps"
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
  server_id        = azurerm_mssql_server.sql_server.id

  depends_on = [
    azurerm_mssql_server.sql_server
  ]
}

# Enable Vnet integration
resource "azurerm_mssql_virtual_network_rule" "sqlvnetrule" {
  count = length(var.subnets)

  name      = "sql-vnet-rule-${count.index}"
  server_id = azurerm_mssql_server.sql_server.id
  subnet_id = var.subnets[count.index]

  depends_on = [
    azurerm_mssql_server.sql_server
  ]
}

resource "azurerm_mssql_server_transparent_data_encryption" "tde" {
  server_id = azurerm_mssql_server.sql_server.id
}

resource "azurerm_key_vault_secret" "admin_user_secret" {
  name            = "sql-admin-user-name"
  value           = var.sql_admin_username
  key_vault_id    = var.key_vault_id
  expiration_date = local.secret_expiration_date
  content_type    = "text/plain"
}

resource "azurerm_key_vault_secret" "admin_pswd_secret" {
  name            = "sql-admin-password"
  value           = random_password.password[0].result
  key_vault_id    = var.key_vault_id
  expiration_date = local.secret_expiration_date
  content_type    = "text/plain"

  depends_on = [
    random_password.password
  ]
}

resource "azurerm_key_vault_secret" "db_rw_user_name_secret" {
  for_each        = var.sql_databases
  name            = "${each.value.sql_database_name}-readwrite-user"
  value           = "${each.value.sql_database_name}-rw-user"
  key_vault_id    = var.key_vault_id
  expiration_date = local.secret_expiration_date
  content_type    = "text/plain"
}

resource "azurerm_key_vault_secret" "db_ro_user_name_secret" {
  for_each        = var.sql_databases
  name            = "${each.value.sql_database_name}-readonly-user"
  value           = "${each.value.sql_database_name}-ro-user"
  key_vault_id    = var.key_vault_id
  expiration_date = local.secret_expiration_date
  content_type    = "text/plain"
}

resource "azurerm_key_vault_secret" "db_rw_password_secret" {
  for_each        = var.sql_databases
  name            = "${each.value.sql_database_name}-readwrite-pwd"
  value           = random_password.password[1].result
  key_vault_id    = var.key_vault_id
  expiration_date = local.secret_expiration_date
  content_type    = "text/plain"

  depends_on = [
    random_password.password
  ]
}

resource "azurerm_key_vault_secret" "db_ro_password_secret" {
  for_each        = var.sql_databases
  name            = "${each.value.sql_database_name}-readonly-pwd"
  value           = random_password.password[2].result
  key_vault_id    = var.key_vault_id
  expiration_date = local.secret_expiration_date
  content_type    = "text/plain"

  depends_on = [
    random_password.password
  ]
}

# add diagnostic settings
resource "azurerm_monitor_diagnostic_setting" "sql_diag_setting" {
  for_each                       = var.sql_databases
  name                           = var.diag_setting_name
  target_resource_id             = azurerm_mssql_database.sql_database[each.key].id
  eventhub_name                  = var.eventhub_name
  eventhub_authorization_rule_id = var.eventhub_authorization_rule_id

  dynamic "log" {
    //for_each = data.azurerm_monitor_diagnostic_categories.sql_database_diag_categories.logs
    for_each = local.diag_log_categories
    iterator = category
    content {
      category = category.value
      enabled  = true
    }
  }

  depends_on = [
    azurerm_mssql_server.sql_server,
    azurerm_mssql_database.sql_database
  ]
}

resource "azurerm_mssql_database_extended_auditing_policy" "sql_audit_policy" {
  for_each                                = toset([for v in azurerm_mssql_database.sql_database : v.id])
  database_id                             = each.value
  storage_endpoint                        = data.azurerm_storage_account.storage.primary_blob_endpoint
  storage_account_access_key              = data.azurerm_storage_account.storage.primary_access_key
  storage_account_access_key_is_secondary = false
  retention_in_days                       = 14

  depends_on = [
    azurerm_mssql_database.sql_database,
    data.azurerm_storage_account.storage
  ]
}

resource "azurerm_advanced_threat_protection" "atp" {
  for_each           = toset([for v in azurerm_mssql_database.sql_database : v.id])
  target_resource_id = each.value
  enabled            = true

  depends_on = [
    azurerm_mssql_database.sql_database
  ]
}


# create sql logins
# resource "null_resource" "sql_logins" {
#   for_each = var.sql_databases

#   provisioner "local-exec" {
#     command = <<EOT
#       /tools/azurecli/azurecli-2.29.2/bin/python3 -m pip install mssql-cli
#       sed -i "s|python -m mssqlcli.main|python3 -m mssqlcli.main|g" /tools/azurecli/azurecli-2.29.2/bin/mssql-cli
#       mssql-cli --version

#       sed  -e "s/__User1Name__/$USER_NAME_1/g; s/__User1Pwd__/$USER_PSWD_1/g; s/__User2Name__/$USER_NAME_2/g; s/__User2Pwd__/$USER_PSWD_2/g" "$PWD/../../modules/sql-server/scripts/create-user-logins.sql" > "$PWD/../../modules/sql-server/scripts/create-user-logins.tmp.sql"      

#       mssql-cli -S $SQL_SERVER -d master -U $ADMIN_USER_NAME -P $ADMIN_PSWD  -i "$PWD/../../modules/sql-server/scripts/create-user-logins.tmp.sql" -N -C -l 60

#     EOT
#     environment = {
#       SQL_SERVER      = "tcp:${local.sql_server_name}.database.windows.net,1433"
#       ADMIN_USER_NAME = "${var.sql_admin_username}"
#       ADMIN_PSWD      = "${random_password.password[0].result}"
#       USER_NAME_1     = "${each.value.sql_database_name}-rw-user"
#       USER_NAME_2     = "${each.value.sql_database_name}-rw-user"
#       USER_PSWD_1     = "${random_password.password[1].result}"
#       USER_PSWD_2     = "${random_password.password[2].result}"
#     }
#   }

#   depends_on = [
#     azurerm_mssql_server.sql_server,
#     azurerm_mssql_database.sql_database
#   ]
# }

# # run scripts in sql database 
# resource "null_resource" "db_scripts" {
#   for_each = var.sql_databases

#   provisioner "local-exec" {
#     command = <<EOT
#       sed  -e "s/__User1Name__/$USER_NAME_1/g; s/__User2Name__/$USER_NAME_2/g; " "$PWD/../../modules/sql-server/scripts/$database/create-users.sql" > "$PWD/../../modules/sql-server/scripts/$database/create-users.tmp.sql"
#       mssql-cli -S $SQL_SERVER -d $SQL_DATABASE -U $ADMIN_USER_NAME -P $ADMIN_PSWD  -i "$PWD/../../modules/sql-server/scripts/create-users.tmp.sql" -N -C -l 60
#     EOT  
#     environment = {
#       SQL_SERVER      = "tcp:${local.sql_server_name}.database.windows.net,1433"
#       SQL_DATABASE    = "${each.value.sql_database_name}"
#       ADMIN_USER_NAME = "${var.sql_admin_username}"
#       ADMIN_PSWD      = "${random_password.password[0].result}"
#       USER_NAME_1     = "${each.value.sql_database_name}-rw-user"
#       USER_NAME_2     = "${each.value.sql_database_name}-ro-user"
#     }
#   }

#   depends_on = [
#     azurerm_mssql_server.sql_server,
#     azurerm_mssql_database.sql_database,
#     null_resource.sql_logins
#   ]
# }


