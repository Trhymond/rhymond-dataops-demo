data "azurerm_client_config" "current" {}

data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

locals {
  arm_deploy_name = replace(replace(lower("${var.project_name}-${var.environment_name}-${var.location_short_name}-arm"), "-", "_"), " ", "_")
}

# data "local_file" "arm_template_file" {
#   filename = var.arm_template_json
# }

# data "local_file" "arm_template_param_file" {
#   filename = var.arm_template_parameters_json
# }

resource "random_integer" "random" {
  min = 1
  max = 9999
}

resource "azurerm_resource_group_template_deployment" "arm_deploy" {
  count               = fileexists(var.arm_template_json) ? 1 : 0
  name                = "${local.arm_deploy_name}_${random_integer.random.result}"
  resource_group_name = data.azurerm_resource_group.rg.name
  deployment_mode     = "Incremental"

  # parameters_content = jsonencode(data.local_file.arm_template_param_file.content)
  parameters_content = file(var.arm_template_parameters_json)
  # template_content   = jsonencode(data.local_file.arm_template_file.content)
  template_content = file(var.arm_template_json)

  depends_on = [
    # data.local_file.arm_template_file,
    # data.local_file.arm_template_param_file,
    random_integer.random
  ]
}


