data "azurerm_client_config" "current" {}

data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

data "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  resource_group_name = data.azurerm_resource_group.rg.name
}

locals {
  nsg_name = lower("${var.nsg_name_prefix}-${var.environment_name}-${var.location_short_name}-nsg")
}

resource "azurerm_network_security_group" "nsg" {
  count               = local.nsg_name == "" ? 0 : 1
  name                = local.nsg_name
  resource_group_name = var.nsg_resource_group == "" ? data.azurerm_resource_group.rg.name : var.nsg_resource_group
  location            = data.azurerm_resource_group.rg.location
  tags = merge(var.tags, {
    category = "Network"
  })
}

resource "azurerm_network_security_rule" "nsg_rules" {
  for_each                    = var.nsg_rules
  name                        = each.key
  resource_group_name         = var.nsg_resource_group == "" ? data.azurerm_resource_group.rg.name : var.nsg_resource_group
  network_security_group_name = local.nsg_name
  priority                    = each.value.priority
  direction                   = each.value.direction
  access                      = each.value.access
  protocol                    = each.value.protocol
  source_address_prefix       = each.value.source_address_prefix
  source_port_range           = each.value.source_port_range
  destination_address_prefix  = each.value.destination_address_prefix
  destination_port_range      = each.value.destination_port_ranges[0] == "*" ? "*" : null
  destination_port_ranges     = each.value.destination_port_ranges[0] == "*" ? null : each.value.destination_port_ranges
  #destination_port_ranges = each.value.destination_port_ranges

  depends_on = [
    azurerm_network_security_group.nsg
  ]
}

resource "azurerm_subnet" "subnets" {
  for_each                                       = var.subnets
  name                                           = each.key
  resource_group_name                            = data.azurerm_resource_group.rg.name
  virtual_network_name                           = var.vnet_name
  address_prefixes                               = each.value.address_prefix
  enforce_private_link_endpoint_network_policies = each.value.disable_endppoint_network_policies != null ? each.value.disable_endppoint_network_policies : null
  enforce_private_link_service_network_policies  = each.value.disable_service_network_policies != null ? each.value.disable_service_network_policies : null

  service_endpoints = length(each.value.service_endpoints) > 0 ? each.value.service_endpoints : null

  dynamic "delegation" {
    for_each = each.value.service_delegation != null ? each.value.service_delegation : []
    iterator = dlg
    content {
      name = "${delegation.value.name}-delegation"
      service_delegation {
        name    = dlg.value.name
        actions = dlg.value.actions
      }
    }
  }

  depends_on = [
    data.azurerm_virtual_network.vnet
  ]
}

resource "azurerm_subnet_network_security_group_association" "subnet_nsg" {
  for_each                  = toset([for k, v in var.subnets : k if v.attach_nsg == true])
  subnet_id                 = azurerm_subnet.subnets[each.key].id
  network_security_group_id = azurerm_network_security_group.nsg.0.id

  depends_on = [
    azurerm_network_security_group.nsg,
    azurerm_subnet.subnets
  ]
}


