data "azurerm_client_config" "current" {}

data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

locals {
  storage_account_name   = replace(lower("${var.project_name}-${var.environment_name}-${var.location_short_name}-sto"), "-", "")
  current_time           = timestamp()
  expiration_hours       = var.secret_expiration_days * 24
  secret_expiration_date = formatdate("YYYY-MM-DD", timeadd(local.current_time, "${local.expiration_hours}h"))
}

resource "azurerm_storage_account" "storage" {
  #checkov:skip=CKV_AZURE_33: "Ensure Storage logging is enabled for Queue service for read, write and delete requests"

  name                = local.storage_account_name
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  tags = merge(var.tags, {
    category = "Storage"
  })

  account_kind              = "StorageV2"
  account_tier              = var.storage_account_tier
  account_replication_type  = var.storage_account_replication_type
  access_tier               = "Hot"
  enable_https_traffic_only = true
  min_tls_version           = "TLS1_2"
  is_hns_enabled            = false

  network_rules {
    default_action = "Deny"
  }

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_storage_share" "storage_fileshares" {
  count = length(var.storage_fileshares)

  name                 = var.storage_fileshares[count.index].name
  storage_account_name = local.storage_account_name
  quota                = var.storage_fileshares[count.index].quota
  enabled_protocol     = "SMB"
  access_tier          = "TransactionOptimized"

  depends_on = [
    azurerm_storage_account.storage
  ]
}


resource "azurerm_key_vault_key" "storage_cmk_key" {
  #checkov:skip=CKV_AZURE_112: "Ensure that key vault key is backed by HSM"
  name            = "${local.storage_account_name}-key"
  key_vault_id    = var.keyvault_id
  key_type        = "RSA"
  key_size        = 2048
  key_opts        = ["decrypt", "encrypt", "sign", "unwrapKey", "verify", "wrapKey"]
  expiration_date = local.secret_expiration_date
}

resource "azurerm_storage_account_customer_managed_key" "storage_cmk" {
  storage_account_id = azurerm_storage_account.storage.id
  key_vault_id       = var.keyvault_id
  key_name           = azurerm_key_vault_key.storage_cmk_key.name

  depends_on = [
    azurerm_key_vault_key.storage_cmk_key
  ]
}
