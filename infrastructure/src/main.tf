
module "landing_zone_rg" {
  source              = "./modules/resource-group"
  environment_name    = var.environment_name
  project_name        = var.project_name
  resource_group_name = var.landing_zone_resource_group_name
  location_short_name = var.location_short_name
  tags                = var.tags
  location            = var.location
}

module "data_zone_rg" {
  source              = "./modules/resource-group"
  environment_name    = var.environment_name
  project_name        = var.project_name
  resource_group_name = var.landing_zone_resource_group_name
  location_short_name = var.location_short_name
  tags                = var.tags
  location            = var.location
}


// Virtual Network
module "network" {
  source = "./modules/network/vnet"

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
  source = "./modules/log-analytics"

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
  source = "./modules/application-insights"

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
module "keyvault" {
  source = "./modules/key-vault"

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
  source = "./modules/storage-account"

  environment_name    = var.environment_name
  project_name        = var.project_name
  resource_group_name = module.landing_zone_rg.name
  location_short_name = var.location_short_name
  tags                = var.tags

  storage_account_tier             = var.storage_account_tier
  storage_account_replication_type = var.storage_account_replication_type
  keyvault_id                      = module.keyvault.id
  secret_expiration_days           = var.secret_expiration_days

  depends_on = [
    module.landing_zone_rg
  ]
}

module "data_factory" {
  source = "./modules/data-factory"

  environment_name    = var.environment_name
  project_name        = var.project_name
  resource_group_name = module.data_zone_rg.name
  location_short_name = var.location_short_name
  tags                = var.tags

  public_network_enabled     = var.data_factory_public_network_enabled
  action_group_shortname     = var.data_factory_action_group_shortname
  alert_email_receivers      = var.data_factory_alert_email_receivers
  keyvault_id                = module.keyvault.id
  log_analytics_workspace_id = module.log_analytics.workspace_id

  depends_on = [
    module.data_zone_rg,
    module.keyvault,
    module.log_analytics
  ]
}

module "databricks" {
  source = "./modules/databricks"

  environment_name    = var.environment_name
  project_name        = var.project_name
  resource_group_name = module.data_zone_rg.name
  location_short_name = var.location_short_name
  tags                = var.tags

  sku                        = var.databricks_sku
  no_public_ip               = var.databricks_no_public_ip
  virtual_network_id         = module.network.id
  public_subnet_name         = var.databricks_public_subnet_name
  private_subnet_name        = var.databricks_private_subnet_name
  public_nsg_association_id  = module.network.subnets["public-databricks-snet"].id
  private_nsg_association_id = module.network.subnets["private-databricks-snet"].id

  depends_on = [
    module.data_zone_rg,
    module.network
  ]
}

module "data_lake" {
  source = "./modules/data-lake"

  environment_name    = var.environment_name
  project_name        = var.project_name
  resource_group_name = module.data_zone_rg.name
  location_short_name = var.location_short_name
  tags                = var.tags

  storage_account_tier             = var.datalake_storage_account_tier
  storage_account_replication_type = var.datalake_storage_account_replication_type
  keyvault_id                      = module.keyvault.id

  datalake_containers = {
    "bronze" = { scope = "access", type = "user", id = "99331b05-b78e-4c92-9e8a-5c7d42a36c1a", perm = "rwx" },
    "silver" = { scope = "access", type = "user", id = "99331b05-b78e-4c92-9e8a-5c7d42a36c1a", perm = "rwx" },
    "gold"   = { scope = "access", type = "user", id = "99331b05-b78e-4c92-9e8a-5c7d42a36c1a", perm = "rwx" },
  }

  datalake_container_paths = [
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
    module.data_zone_rg
  ]
}

module "synapse_analytics" {
  source = "./modules/synapse-analytics"

  environment_name    = var.environment_name
  project_name        = var.project_name
  resource_group_name = module.data_zone_rg.name
  location_short_name = var.location_short_name
  tags                = var.tags

  sqlpool_sku_name        = var.sqlpool_sku_name
  datalake_filesystem_id  = module.data_lake.filesystems["gold"].id
  keyvault_id             = module.keyvault.id
  secret_expiration_days  = var.secret_expiration_days
  sqlpool_admin_user_name = var.sqlpool_admin_user_name

  depends_on = [
    module.data_zone_rg,
    module.data_lake
  ]
}

module "dashboard" {
  source = "./modules/dashboard"

  resource_group_name = module.data_zone_rg.name
  tags                = var.tags
  datafactory_name    = module.data_factory.name

  depends_on = [
    module.data_zone_rg
  ]
}


