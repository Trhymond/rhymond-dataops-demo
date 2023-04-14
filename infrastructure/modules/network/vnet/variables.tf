
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

variable "vnet_address_space" {
  description = "The virtual network address spaces"
  type        = list(string)
}

variable "ddos_protection_plan_id" {
  description = "The DDos protextion plan id"
  type        = string
}

variable "nsg_rules" {
  description = "The network security group rules"
  type = map(object({
    priority                   = number
    direction                  = string
    access                     = string
    protocol                   = string
    source_address_prefix      = string
    source_port_range          = string
    destination_address_prefix = string
    destination_port_ranges    = list(string)
  }))
}

variable "subnets" {
  description = "The subnets in the virtual network"
  type = map(object({
    address_prefix                     = list(string)
    attach_nsg                         = bool
    disable_endppoint_network_policies = bool
    disable_service_network_policies   = bool
    service_endpoints                  = list(string)
    service_delegation = list(object({
      name    = string
      actions = list(string)
    }))
  }))
}



