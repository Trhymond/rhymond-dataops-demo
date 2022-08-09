data "azurerm_client_config" "current" {}

data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

locals {
  storage_account_name = replace(lower("${var.project_name}-${var.environment_name}-${var.location_short_name}-sto"), "-", "")

  storage_account_network_acls = var.storage_account_network_acls == null || length(var.storage_account_network_acls) == 0 ? merge(var.storage_account_network_acls, {
    bypass         = ["AzureServices"],
    default_action = "Allow",
  }) : var.storage_account_network_acls


  # storage_account_role_assignments_hash_map = {
  #   for assignment in var.storage_account_role_assignments :
  #   md5("${assignment.principal_id}${assignment.role_definition_name}") => assignment
  # }

  datalake_container_paths = {
    for path_object in var.datalake_container_paths :
    md5("${path_object.container_name}${path_object.path_name}") => path_object
  }
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
  is_hns_enabled            = true


  dynamic "network_rules" {
    for_each = local.storage_account_network_acls
    iterator = acl
    content {
      bypass                     = acl.value.bypass
      default_action             = acl.value.default_action
      ip_rules                   = acl.value.ip_rules
      virtual_network_subnet_ids = acl.value.virtual_network_subnet_ids == null ? null : acl.value.virtual_network_subnet_ids
    }
  }

  identity {
    type = "SystemAssigned"
  }
}


resource "azurerm_storage_data_lake_gen2_filesystem" "data_lake_files" {
  for_each           = var.datalake_containers
  storage_account_id = azurerm_storage_account.storage.id
  name               = each.key
  ace {
    scope       = each.value["scope"]
    type        = each.value["type"]
    id          = each.value["id"]
    permissions = each.value["perm"]
  }

  depends_on = [
    azurerm_storage_account.storage
  ]
}

resource "azurerm_storage_data_lake_gen2_path" "data_lake_path" {
  for_each           = local.datalake_container_paths
  storage_account_id = azurerm_storage_account.storage.id
  path               = each.value.path_name
  filesystem_name    = azurerm_storage_data_lake_gen2_filesystem.data_lake_files[each.value.container_name].name
  resource           = try(each.value.resource_type, "directory")

  depends_on = [
    azurerm_storage_account.storage,
    azurerm_storage_data_lake_gen2_filesystem.data_lake_files
  ]
}

resource "azurerm_role_assignment" "role_asgmt" {
  for_each             = var.storage_account_role_assignments
  scope                = azurerm_storage_account.storage.id
  role_definition_name = each.value.role_definition_name
  principal_id         = each.value.principal_id

  depends_on = [
    azurerm_storage_account.storage
  ]
}
