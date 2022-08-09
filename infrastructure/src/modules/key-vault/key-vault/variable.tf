
variable "environment_name" {
  description = "The environment name"
  type        = string
}

variable "project_name" {
  description = "The application name"
  type        = string
}

variable "domain_name" {
  description = "The domain name"
  type        = string
  default     = ""
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

variable "instance_id" {
  description = "The keyvault instance id"
  type        = number
}

variable "sku_name" {
  description = "The keyvault sku name"
  type        = string
  default     = "standard"
}

variable "ip_rules" {
  description = "The keyvault ip restrictions"
  type        = list(string)
}

variable "subnet_ids" {
  description = "The keyvault selected network ids"
  type        = list(string)
}

variable "access_policies" {
  description = "The keyvault access policies"
  type = list(object({
    name           = string
    object_id      = string
    application_id = string
  }))
}


