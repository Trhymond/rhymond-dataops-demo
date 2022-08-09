
module "landing_zone_rg" {
  source              = "../modules/resource-group"
  environment_name    = var.environment_name
  project_name        = var.project_name
  resource_group_name = var.landing_zone_resource_group_name
  location_short_name = var.location_short_name
  tags                = var.tags
  location            = var.location
}


// Virtual Network
module "network" {
  source = "../modules/network/vnet"

  environment_name        = var.environment_name
  project_name            = var.project_name
  resource_group_name     = module.landing_zone_rg.name
  location_short_name     = var.location_short_name
  tags                    = var.tags
  vnet_address_space      = var.vnet_address_space
  ddos_protection_plan_id = var.ddos_protection_plan_id
  nsg_rules               = var.nsg_rules
  subnets                 = var.subnets

  depends_on = [
    module.landing_zone_rg
  ]
}

// Log Analytics Workspace
module "log_analytics" {
  source = "../modules/log-analytics"

  environment_name    = var.environment_name
  project_name        = var.project_name
  resource_group_name = module.landing_zone_rg.name
  location_short_name = var.location_short_name
  tags                = var.tags
  sku_name            = var.log_analytics_sku_name
  retention_in_days   = var.log_analytics_retention_in_days

  depends_on = [
    module.landing_zone_rg
  ]
}


// AppInsights
module "app_insight" {
  source = "../modules/application-insights"

  environment_name           = var.environment_name
  project_name               = var.project_name
  resource_group_name        = module.landing_zone_rg.name
  location_short_name        = var.location_short_name
  tags                       = var.tags
  log_analytics_workspace_id = module.log_analytics.workspace_id

  depends_on = [
    module.landing_zone_rg,
    module.log_analytics
  ]
}

// Key Vault
module "landing_zone_keyvault" {
  source = "../modules/key-vault/key-vault"

  environment_name    = var.environment_name
  project_name        = var.project_name
  resource_group_name = module.landing_zone_rg.name
  location_short_name = var.location_short_name
  tags                = var.tags
  instance_id         = var.keyvault_instance_id
  sku_name            = var.keyvault_sku_name
  ip_rules            = var.keyvault_ip_rules
  subnet_ids          = toset([for v in module.network.subnets : v.id])
  access_policies     = var.keyvault_access_policies

  depends_on = [
    module.landing_zone_rg,
    module.network
  ]
}

module "storage_account" {
  source = "../modules/storage-account"

  environment_name    = var.environment_name
  project_name        = var.project_name
  resource_group_name = module.landing_zone_rg.name
  location_short_name = var.location_short_name
  tags                = var.tags

  storage_tier             = var.storage_tier
  storage_replication_type = var.storage_replication_type
  storage_fileshares       = var.storage_fileshares
  keyvault_id              = module.landing_zone_keyvault.id
  secret_expiration_days   = var.secret_expiration_days

  depends_on = [
    module.landing_zone_rg
  ]
}

module "data_lake" {
  source = "../modules/data-lake"

  environment_name    = var.environment_name
  project_name        = var.project_name
  resource_group_name = module.landing_zone_rg.name
  location_short_name = var.location_short_name
  tags                = var.tags

  storage_tier             = var.storage_tier
  storage_replication_type = var.storage_replication_type

  data_lake_containers = {
    "bronze" = { scope = "access", type = "user", id = "99331b05-b78e-4c92-9e8a-5c7d42a36c1a", perm = "rwx" },
    "silver" = { scope = "access", type = "user", id = "99331b05-b78e-4c92-9e8a-5c7d42a36c1a", perm = "rwx" },
    "gold"   = { scope = "access", type = "user", id = "99331b05-b78e-4c92-9e8a-5c7d42a36c1a", perm = "rwx" },
  }

  data_lake_container_paths = [
    { container_name = "bronze", path_name = "con01" },
    { container_name = "silver", path_name = "con01" },
    { container_name = "silver", path_name = "con02" },
    { container_name = "gold", path_name = "con01" }
  ]

  storage_account_network_acls = {
    bypass                     = ["AzureServices"]
    default_action             = "Deny"
    ip_rules                   = ["any"]
    virtual_network_subnet_ids = []
  }

  depends_on = [
    module.landing_zone_rg
  ]
}



