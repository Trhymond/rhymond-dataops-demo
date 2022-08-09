data "azurerm_client_config" "current" {}

data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

data "http" "public_ip" {
  url = "https://ifconfig.co/json"

  request_headers = {
    Accept = "application/json"
  }
}

locals {

  keyvault_name_base = substr("${var.project_name}-${var.environment_name}-${var.location_short_name}", 0, 19)
  keyvault_name      = lower("${local.keyvault_name_base}-kv-${var.instance_id}")
  ifconfig_co_json   = jsondecode(data.http.public_ip.body)
}

resource "azurerm_key_vault" "kv" {
  name                = local.keyvault_name
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  tags = merge(var.tags, {
    "criticallity" = "High",
  })

  tenant_id                       = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days      = 90
  purge_protection_enabled        = true
  enabled_for_deployment          = true
  enabled_for_disk_encryption     = true
  enabled_for_template_deployment = true
  enable_rbac_authorization       = false

  sku_name = var.sku_name

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions         = ["Get", "List"]
    secret_permissions      = ["Get", "List", "Set"]
    certificate_permissions = ["Get", "List", "Create", "Update", "Delete", "Import", "Purge"]
  }

  dynamic "access_policy" {
    for_each = var.access_policies
    content {
      tenant_id      = data.azurerm_client_config.current.tenant_id
      object_id      = access_policy.value["object_id"]
      application_id = access_policy.value["application_id"]

      key_permissions         = ["Get", "List", "Create", "Update"]
      secret_permissions      = ["Get", "List", "Set"]
      certificate_permissions = ["Get", "List", "Create", "Update", "Delete", "Import", "Purge"]
    }
  }

  # Microsoft Azure CLI
  access_policy {
    tenant_id      = data.azurerm_client_config.current.tenant_id
    object_id      = "2d5bf8d7-3116-4d46-a951-65a94082e92b"
    application_id = "04b07795-8ddb-461a-bbee-02f9e1bf7b46"

    key_permissions         = ["Get", "List", "Create", "Update"]
    secret_permissions      = ["Get", "List", "Set"]
    certificate_permissions = ["Get", "List", "Create", "Update", "Delete", "Import", "Purge"]
  }

  # azure_devops_nonprod
  access_policy {
    tenant_id      = data.azurerm_client_config.current.tenant_id
    object_id      = "22a5ec62-ad8b-4f3a-b2fe-f566170f1a8d"
    application_id = "df555efd-6de0-4370-a12a-d3401abfcbce"

    key_permissions         = ["Get", "List", "Create", "Update"]
    secret_permissions      = ["Get", "List", "Set"]
    certificate_permissions = ["Get", "List", "Create", "Update", "Delete", "Import", "Purge"]
  }

  network_acls {
    bypass                     = "AzureServices"
    default_action             = "Deny"
    ip_rules                   = concat(var.ip_rules, formatlist(local.ifconfig_co_json.ip))
    virtual_network_subnet_ids = var.subnet_ids
  }

  depends_on = [
    data.http.public_ip
  ]
}


