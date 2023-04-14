
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

variable "sku" {
  description = " (Required) The sku to use for the Databricks Workspace. Possible values are standard, premium, or trial. Changing this can force a new resource to be created in some circumstances."
  type        = string
  default     = "standard"
}

variable "no_public_ip" {
  description = "(Optional) Are public IP Addresses not allowed? Possible values are true or false. Defaults to false. Changing this forces a new resource to be created."
  type        = bool
}

variable "virtual_network_id" {
  description = "(Optional) The ID of a Virtual Network where this Databricks Cluster should be created. Changing this forces a new resource to be created."
  type        = string
}

variable "public_subnet_name" {
  description = "(Optional) The name of the Public Subnet within the Virtual Network. Required if virtual_network_id is set. Changing this forces a new resource to be created."
  type        = string
}

variable "private_subnet_name" {
  description = "(Optional) The name of the Private Subnet within the Virtual Network. Required if virtual_network_id is set. Changing this forces a new resource to be created."
  type        = string
}

variable "public_nsg_association_id" {
  description = "The resource ID of the azurerm_subnet_network_security_group_association resource which is referred to by the public_subnet_name field. Required if virtual_network_id is set."
  type        = string
}

variable "private_nsg_association_id" {
  description = "The resource ID of the azurerm_subnet_network_security_group_association resource which is referred to by the public_subnet_name field. Required if virtual_network_id is set."
  type        = string
}




