
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

variable "public_network_enabled" {
  description = "(Optional) Is the Data Factory visible to the public network? Defaults to true."
  type        = string
}

variable "keyvault_id" {
  description = "The  keyvault id"
  type        = string
}


variable "secret_expiration_days" {
  type        = number
  description = "The keyvault secret expiration days from the date of add"
  default     = 90
}

variable "log_analytics_workspace_id" {
  description = "The  log analytics workspace id"
  type        = string
}

variable "action_group_shortname" {
  description = "The action group short name"
  type        = string
}

variable "alert_email_receivers" {
  description = "The action group short name"
  type = list(object({
    name          = string
    email_address = string
  }))
}







