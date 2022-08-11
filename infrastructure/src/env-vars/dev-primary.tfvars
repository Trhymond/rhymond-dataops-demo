environment_name                 = "dev"
project_name                     = "Riders"
landing_zone_resource_group_name = "iac-landingzone"
data_resource_group_name         = "iac-datazone"
location_short_name              = "us-e"
location                         = "East US"

tags = {
  "cost-center" : "021922",
  "owner" : "tomy.rhymond@slalom.com",
  "env" : "Non Prod-Dev",
  "region" : "eastus"
  "project-name" : "DataOpsDemo"
  "deploy-mode" : "terraform iac"
  "iac-source" : ""
}

# Network
vnet_address_space = [
  "10.0.0.0/16"
]

ddos_protection_plan_id = null

nsg_rules = {
  "Allow_Azure_LoadBalancer" = {
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_address_prefix      = "AzureLoadBalancer"
    source_port_range          = "*"
    destination_address_prefix = "VirtualNetwork"
    destination_port_ranges    = ["0-65535"]
    description                = "Dependencies to Azure Load Balancer"
  },
  "Allow_Azure_Storage" = {
    priority                   = 300
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_address_prefix      = "VirtualNetwork"
    source_port_range          = "*"
    destination_address_prefix = "Storage"
    destination_port_ranges    = ["443"]
    description                = "APIM service dependency on Azure Blob and Azure Table Storage"
  },
  "Allow_AzureSQL" = {
    priority                   = 310
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_address_prefix      = "VirtualNetwork"
    source_port_range          = "*"
    destination_address_prefix = "Sql"
    destination_port_ranges    = ["1433"]
    description                = "Azure SQL dependencies"
  },
  "Allow_EventHub_Policy" = {
    priority                   = 320
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_address_prefix      = "VirtualNetwork"
    source_port_range          = "*"
    destination_address_prefix = "EventHub"
    destination_port_ranges    = ["5671"]
    description                = "EventHub policy dependencies"
  },
  "Allow_AzureAD_Authentication" = {
    priority                   = 330
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_address_prefix      = "VirtualNetwork"
    source_port_range          = "*"
    destination_address_prefix = "AzureActiveDirectory"
    destination_port_ranges    = ["80", "443"]
    description                = "Connect to Azure Active Directory for Developer Portal Authentication or for Oauth2 flow during any Proxy Authentication"
  },
  "Allow_Publish_Monitor_Logs" = {
    priority                   = 340
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_address_prefix      = "VirtualNetwork"
    source_port_range          = "*"
    destination_address_prefix = "AzureCloud"
    destination_port_ranges    = ["443"]
    description                = "Publish Monitor Logs to Azure"
  },
  "Allow_KeyVault" = {
    priority                   = 350
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_address_prefix      = "VirtualNetwork"
    source_port_range          = "*"
    destination_address_prefix = "AzureKeyVault"
    destination_port_ranges    = ["443"]
    description                = "Dependencies to Azure KeyVault"
  },
  "Deny_All_Internet" = {
    priority                   = 360
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_address_prefix      = "*"
    source_port_range          = "*"
    destination_address_prefix = "Internet"
    destination_port_ranges    = ["0-65535"]
    description                = "Deny all outbound internet traffic"
  }
}

subnets = {
  "AzureFirewallSubnet" = {
    address_prefix                     = ["10.0.0.0/26"]
    service_endpoints                  = ["Microsoft.AzureCosmosDB", "Microsoft.Storage", "Microsoft.KeyVault", "Microsoft.Sql"]
    attach_nsg                         = false
    disable_endppoint_network_policies = null
    disable_service_network_policies   = null
    service_delegation                 = null
  },
  "data-snet" = {
    address_prefix                     = ["10.0.1.0/24"]
    service_endpoints                  = ["Microsoft.AzureCosmosDB", "Microsoft.Sql", "Microsoft.KeyVault"]
    attach_nsg                         = true
    disable_endppoint_network_policies = null
    disable_service_network_policies   = null
    service_delegation                 = null
  },
  "public-databricks-snet" = {
    address_prefix                     = ["10.0.2.0/24"]
    service_endpoints                  = ["Microsoft.KeyVault", "Microsoft.Sql", "Microsoft.Storage"]
    attach_nsg                         = true
    disable_endppoint_network_policies = null
    disable_service_network_policies   = null
    service_delegation                 = null
  },
  "private-databricks-snet" = {
    address_prefix                     = ["10.0.3.0/24"]
    service_endpoints                  = ["Microsoft.KeyVault", "Microsoft.Sql", "Microsoft.Storage"]
    attach_nsg                         = true
    disable_endppoint_network_policies = null
    disable_service_network_policies   = null
    service_delegation                 = null
  }
}

# Log Analytics
log_analytics_sku_name          = "PerGB2018"
log_analytics_retention_in_days = "30"


# Key Vault
keyvault_instance_id = 5
keyvault_sku_name    = "standard"
keyvault_ip_rules    = []
keyvault_access_policies = [
  { name = "Microsoft Azure CLI", object_id = "2d5bf8d7-3116-4d46-a951-65a94082e92b", application_id = "04b07795-8ddb-461a-bbee-02f9e1bf7b46" },
  { name = "azure_devops_nonprod", object_id = "22a5ec62-ad8b-4f3a-b2fe-f566170f1a8d", application_id = "df555efd-6de0-4370-a12a-d3401abfcbce" }
]
secret_expiration_days = 90

#Storage Account
storage_account_tier             = "Standard"
storage_account_replication_type = "LRS"


# Data Factory
data_factory_public_network_enabled = true
data_factory_action_group_shortname = ""
data_factory_alert_email_receivers = [{
  name          = "Tomy Rhymond"
  email_address = "tomy.rhymond@slalom.com"
}]

# Databricks
databricks_sku                 = "premium"
databricks_no_public_ip        = true
databricks_public_subnet_name  = "public-databricks-snet"
databricks_private_subnet_name = "private-databricks-snet"
service_principal_client_id    = "df555efd-6de0-4370-a12a-d3401abfcbce"

# ADLS
datalake_storage_account_tier             = "Standard"
datalake_storage_account_replication_type = "LRS"
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
datalake_storage_account_network_acls = {
  bypass                     = ["AzureServices"]
  default_action             = "Deny"
  ip_rules                   = ["any"]
  virtual_network_subnet_ids = []
}
datalake_storage_account_role_assignments = []

#Synapse
sqlpool_admin_user_name = "synapse_sql_admin"
sqlpool_sku_name        = "DW100c"
# synapse_firewall_rules  = {}
