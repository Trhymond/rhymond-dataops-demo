
data "azurerm_client_config" "current" {}

data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

locals {
  data_factory_name = lower("${var.project_name}-${var.environment_name}-${var.location_short_name}-df")

  current_time           = timestamp()
  expiration_hours       = var.secret_expiration_days * 24
  secret_expiration_date = formatdate("YYYY-MM-DD'T'hh:mm:ssZ", timeadd(local.current_time, "${local.expiration_hours}h"))
}

resource "azurerm_key_vault_key" "adf_cmk_key" {
  #checkov:skip=CKV_AZURE_112: "Ensure that key vault key is backed by HSM"
  name            = "${local.data_factory_name}-key"
  key_vault_id    = var.keyvault_id
  key_type        = "RSA"
  key_size        = 2048
  key_opts        = ["decrypt", "encrypt", "sign", "unwrapKey", "verify", "wrapKey"]
  expiration_date = local.secret_expiration_date
}

resource "azurerm_data_factory" "data_factory" {
  #checkov:skip=CKV_AZURE_103: "Ensure that Azure Data Factory uses Git repository for source control"
  name                = local.data_factory_name
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  tags = merge(var.tags, {
    "app_name" = var.project_name,
  })

  public_network_enabled = var.public_network_enabled

  identity {
    type = "SystemAssigned"
  }

  customer_managed_key_id = azurerm_key_vault_key.adf_cmk_key.id

}

resource "azurerm_data_factory_linked_service_key_vault" "kv_link" {
  name            = "${local.data_factory_name}-kv"
  data_factory_id = azurerm_data_factory.data_factory.id
  key_vault_id    = var.keyvault_id

  depends_on = [
    azurerm_data_factory.data_factory
  ]
}


# add diagnostic settings
resource "azurerm_monitor_diagnostic_setting" "adf_diag_setting" {
  name                       = "${local.data_factory_name}-diag"
  target_resource_id         = azurerm_data_factory.data_factory.id
  log_analytics_workspace_id = var.log_analytics_workspace_id
  log {
    category = "PipelineRuns"
    enabled  = true
  }
  log {
    category = "TriggerRuns"
    enabled  = true
  }
  log {
    category = "ActivityRuns"
    enabled  = true
  }

  metric {
    category = "AllMetrics"
    enabled  = true
  }

  depends_on = [
    azurerm_data_factory.data_factory
  ]
}


resource "azurerm_monitor_action_group" "action_group" {
  name                = "${local.data_factory_name}-action-group"
  resource_group_name = data.azurerm_resource_group.rg.name

  short_name = var.action_group_shortname
  tags       = var.tags

  dynamic "email_receiver" {
    for_each = var.alert_email_receivers
    iterator = receiver
    content {
      name          = receiver.value.name
      email_address = receiver.value.email_address
    }
  }
}

resource "azurerm_monitor_metric_alert" "metric_alert" {
  name                = "${local.data_factory_name}-alert"
  resource_group_name = data.azurerm_resource_group.rg.name
  scopes              = [azurerm_data_factory.data_factory.id]
  description         = "ADF pipeline failed"

  criteria {
    metric_namespace = "Microsoft.DataFactory/factories"
    metric_name      = "PipelineFailedRuns"
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = 1
  }

  frequency                = "PT1M"
  window_size              = "PT5M"
  severity                 = 1
  target_resource_type     = "Microsoft.DataFactory/factories"
  target_resource_location = data.azurerm_resource_group.rg.location

  action {
    action_group_id = azurerm_monitor_action_group.action_group.id
  }
}
