
variable "environment_name" {
  description = "The environment name"
  type        = string
}

variable "project_name" {
  description = "The application name"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "location_short_name" {
  description = "The short name of the resource location"
  type        = string
}

variable "tags" {
  description = "List of resource tags"
  type        = map(any)
}

variable "sql_admin_username" {
  description = "The sql server admin user nmae"
  type        = string
}

/* variable "sql_database_name" {
  description = "The sql database name"
  type        = string
}
 */
/* variable "log_analytics_workspace_id" {
  description = "The id of the log analytics workspace"
  type        = string
}

variable "log_retention_days" {
  description = "The  number of days to retain the log"
  type        = number
} */

variable "keyvault_id" {
  description = "The key vault id"
  type        = string
}

variable "sql_databases" {
  type = map(object({
    sql_database_name = string
    max_size_gb       = number
    sku_name          = string
    zone_redundant    = bool
    diag_settings = map(object({
      diag_setting_name              = string
      eventhub_name                  = string
      eventhub_authorization_rule_id = string
      log                            = string
    }))
    tags = map(any)
  }))
  description = "A list of databases that should be created under SQL Server."
}

variable "sql_server_firewall_rules" {
  type = map(object({
    firwall_rule_name = string
    start_ip_address  = string
    end_ip_address    = string
  }))
  description = "Allows you to manage an Azure SQL Firewall Rule."
}

variable "diag_setting_name" {
  description = "(Required) Specifies the name of the Diagnostic Setting. Changing this forces a new resource to be created."
  type        = string
}

variable "eventhub_name" {
  description = "(Optional) Specifies the name of the Event Hub where Diagnostics Data should be sent. Changing this forces a new resource to be created."
  type        = string
}

variable "eventhub_authorization_rule_id" {
  description = "(Optional) Specifies the ID of an Event Hub Namespace Authorization Rule used to send Diagnostics Data. Changing this forces a new resource to be created."
  type        = string
}

variable "subnets" {
  description = "The subnet id fr vnet integration"
  type        = list(string)
}

variable "sql_ad_admin" {
  description = "The ActiveDirectory admin"
  type = object({
    login_username = string
    object_id      = string
  })
}

variable "secret_expiration_days" {
  type        = number
  description = "The keyvault secret expiration days from the date of add"
  default     = 90
}


