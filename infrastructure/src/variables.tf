
variable "environment_name" {
  description = "The environment name"
  type        = string
}

variable "project_name" {
  description = "The project name"
  type        = string
}

variable "domain_name" {
  description = "The project sub domain name"
  type        = string
}

variable "landing_zone_resource_group_name" {
  description = "The name of the landing zon resource group"
  type        = string
}

variable "product_domain_resource_group_name" {
  description = "The name of the product domain resource group"
  type        = string
}

variable "customer_domain_resource_group_name" {
  description = "The name of the customer domain resource group"
  type        = string
}

variable "location_short_name" {
  description = "The short name of the resource location"
  type        = string
}

variable "location" {
  description = "The name of the resource location"
  type        = string
}

variable "tags" {
  description = "List of resource tags"
  type        = map(any)
}

# Network
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

# Log Analytics 
variable "log_analytics_sku_name" {
  description = "The log analytics workspace sku"
  type        = string
}
variable "log_analytics_retention_in_days" {
  description = "The log analytics workspace log retention in days"
  type        = number
}

# KeyVault
variable "keyvault_instance_id" {
  description = "The keyvault instance id"
  type        = number
}

variable "secret_expiration_days" {
  description = "The keyvault secret expiration days from the date of add"
  type        = number
}

variable "keyvault_product_domain_instance_id" {
  description = "The keyvault product instance id"
  type        = number
}

variable "keyvault_customer_domain_instance_id" {
  description = "The keyvault customer instance id"
  type        = number
}

variable "keyvault_sku_name" {
  description = "The keyvault sku name"
  type        = string
  default     = "standard"
}

variable "keyvault_ip_rules" {
  description = "The keyvault ip restrictions"
  type        = list(string)
}

variable "keyvault_certificate" {
  description = "The certificates to import"
  type = object({
    name      = string
    cert_file = string
    password  = string
  })
  # sensitive = true
}

variable "keyvault_access_policies" {
  description = "The keyvault access policies"
  type = list(object({
    name           = string
    object_id      = string
    application_id = string
  }))
}

#storage account
variable "storage_tier" {
  description = "The tier for the storage account"
  type        = string
}

variable "storage_replication_type" {
  description = "The tier for the storage account"
  type        = string
}

variable "storage_fileshares" {
  description = "The filesshares to create on the storage account"
  type = list(object({
    name  = string
    quota = number
  }))
}
# Container Registry
variable "acr_sku_name" {
  description = "The sku name for container registry"
  type        = string
}

variable "acr_georeplications" {
  description = "The geo replication settings for container registry"
  type = list(object({
    location               = string
    enable_zone_redundancy = bool
  }))
}

variable "acr_network_rule_set" {
  description = "The ip restrictions for container registry"
  type        = object({ default_action = string, ip_rules = list(string) })
}

# AKS API Layer
variable "aks_cluster_sku" {
  description = "The Kubernetes cluster sku"
  type        = string
}

variable "aks_api_version" {
  description = "The Kubernetes version"
  type        = string
}

variable "aks_ms_aad_profile_enabled" {
  description = "Enable AAD Profile "
  type        = bool
}

variable "aks_ms_admin_group_object_ids" {
  description = "The list of admin groups to manage aks cluster"
  type        = list(string)
  default     = []
}

variable "aks_ms_default_node_pool" {
  description = "The default node pool configuration"
  type = object({
    node_count          = number
    vm_size             = string
    enable_auto_scaling = bool
    # mode                 = string
    # os_type              = string
    os_disk_size_gb      = number
    os_disk_type         = string
    max_count            = number
    min_count            = number
    max_pods             = number
    type                 = string
    orchestrator_version = string
  })
}

variable "aks_ms_authorized_ip_ranges" {
  description = "The authorized ip ranges"
  type        = list(string)
  default     = []
}

variable "aks_ms_namespaces" {
  description = "The AKS namespaces"
  type        = list(string)
}

variable "aks_ms_secrets" {
  description = "The AKS Secrets"
  type = list(object({
    name = string
    data = map(any)
  }))
}

// AKS Persistence Layer

variable "aks_pl_aad_profile_enabled" {
  description = "Enable AAD Profile "
  type        = bool
}

variable "aks_pl_admin_group_object_ids" {
  description = "The list of admin groups to manage aks cluster"
  type        = list(string)
  default     = []
}

variable "aks_pl_default_node_pool" {
  description = "The default node pool configuration"
  type = object({
    node_count          = number
    vm_size             = string
    enable_auto_scaling = bool
    # mode                 = string
    # os_type              = string
    os_disk_size_gb      = number
    os_disk_type         = string
    max_count            = number
    min_count            = number
    max_pods             = number
    type                 = string
    orchestrator_version = string
  })
}

variable "aks_pl_authorized_ip_ranges" {
  description = "The authorized ip ranges"
  type        = list(string)
  default     = []
}

variable "aks_pl_namespaces" {
  description = "The AKS namespaces"
  type        = list(string)
}

variable "aks_pl_secrets" {
  description = "The AKS Secrets"
  type = list(object({
    namespace = string
    name      = string
    data      = map(any)
  }))
}

# APIM
variable "apim_sku_name" {
  description = "The apim SKU name"
  type        = string
}

variable "apim_publisher_name" {
  description = "The name of the apim publisher"
  type        = string
}
variable "apim_publisher_email" {
  description = "The apim publisher email"
  type        = string
}

variable "apim_notification_sender_email" {
  description = "The apim notification sender email"
  type        = string
}

variable "apim_gateway_host_name" {
  description = "The gateway hostname for APIM"
  type        = string
}

variable "apim_allow_public_access" {
  description = "Allow public access to apim"
  type        = bool
}

variable "apim_domain_name_label" {
  description = "Label for the Domain Name.Will be used to make up the FQDN."
  type        = string
}

# Application Gateway Policy
variable "waf_managed_rule_group_override" {
  description = "WAF Policy managed rule overrides"
  type = list(object({
    rule_group_name = string
    disabled_rules  = list(string)
  }))
}

variable "waf_managed_rules_exclusions" {
  description = "WAF Policy Managed rules exclusions"
  type = list(object({
    match_variable          = string
    selector                = string
    selector_match_operator = string
  }))
}

variable "waf_custom_rules" {
  description = "WAF Policy custom rules"
  type = list(object({
    name                = string
    priority            = string
    rule_type           = string
    match_variable_name = string
    action              = string
    match_conditions = list(object({
      operator           = string
      negation_condition = bool
      match_values       = list(string)
      transforms         = list(string)
    }))
  }))
}

# Application Gateway

variable "agw_ssl_certificate_name" {
  description = "Application Gateway SSL Cert name"
  type        = string
}

variable "agw_apim_hostname" {
  description = "APIM hostname to integrate with Application Gateway"
  type        = string
}

variable "agw_traffic_config" {
  description = "Application Gateway configuration"
  type = list(object({
    name                               = string
    backend_ip_addresses               = list(string)
    backend_port                       = number
    backend_protocol                   = string
    backend_host_name                  = string
    pick_hostname_from_backend_address = bool
    listener_port                      = number
    listener_protocol                  = string
    listener_hostName                  = string
    probe_protocol                     = string
    probe_path                         = string
  }))
}

# Frontdoor Policy
variable "fd_managed_rules" {
  description = "Frontdoor Policy Managed rules"
  type = list(object({
    name    = string
    version = string
    exclusions = list(object({
      match_variable = string
      selector       = string
      operator       = string
    }))
    overrides = list(object({
      group_name = string
      rules = list(object({
        rule_id = string
        enabled = string
        action  = string
      }))
    }))
  }))
}

variable "fd_custom_rules" {
  description = "Frondoor Policy custom rules"
  type = list(object({
    name      = string
    priority  = string
    rule_type = string
    action    = string

    match_conditions = list(object({
      match_variable     = string
      operator           = string
      negation_condition = bool
      match_values       = list(string)
      transforms         = list(string)
    }))
  }))
}

# Front Door  
variable "fd_frontend_hostname" {
  description = "The Frontdoor hostname"
  type        = string
}

variable "fd_backend_health_probes" {
  description = "The Frontdoor backend health probes"
  type = list(object({
    name     = string
    path     = string
    protocol = string
    method   = string
  }))
}

variable "fd_backend_pools" {
  description = "The Frontdoor backend pools"
  type = list(object({
    name = string
    backends = list(object({
      host_header = string
      address     = string
      priority    = number
      weight      = number
    }))
    health_probe_name = string
  }))
}

variable "fd_routing_rules" {
  description = "The Frontdoor routing rules"
  type = list(object({
    name              = string
    protocols         = list(string)
    patterns_to_match = list(string)
    forwarding_configuration = object({
      protocol          = string
      custom_path       = string
      backend_pool_name = string
    })
    redirect_configuration = object({
      protocol = string
      type     = string
    })
  }))
}



