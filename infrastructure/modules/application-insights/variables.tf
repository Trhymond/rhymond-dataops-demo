
variable "environment_name" {
  description = "The environment name"
  type        = string
}

variable "project_name" {
  description = "The project name"
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

variable "log_analytics_workspace_id" {
  description = "The id of the log analytics workspace"
  type        = string
}

# variable "log_analytics_workspace_name" {
#   description = "The name of the log analytics workspace"
#   type        = string
# }

# variable "log_analytics_workspace_rg" {
#   description = "The resource group of the log analytics workspace"
#   type        = string
# }


