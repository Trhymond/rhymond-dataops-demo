
data "azurerm_client_config" "current" {}

data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

resource "azurerm_portal_dashboard" "dashboard" {
  name                = "Azure-Dashboard"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location

  tags                 = var.tags
  dashboard_properties = <<DASH
    {
        lenses : [
            {
                order : 0
                parts: [
                    position  : {
                        x  : 0  
                        y  : 0  
                        rowSpan  : 4  
                        colSpan  : 6
                    }
                    metadata  : {
                        inputs  : [
                            {
                              name: 'options'
                              isOptional: true
                            }
                            {
                              name: 'sharedTimeRange'
                              isOptional: true
                            }
                        ]       
                        type  :   'Extension/HubsExtension/PartType/MonitorChartPart'         
                        settings  : {
                            content : {
                                options: {
                                    chart: {
                                        metrics: [
                                            resourceMetadata: {
                                                id : '${data.azurerm_client_config.current.subscription_id}/resourceGroups/${data.azurerm_resource_group.rg.name}/providers/Microsoft.DataFactory/factories/${var.datafactory_name}'
                                                name :  'PipelineFailedRuns' 
                                                aggregationType : 1
                                                namespace :  'microsoft.datafactory/factories' 
                                                metricVisualization : {
                                                    displayName :  'Failed pipeline runs metrics' 
                                                    resourceDisplayName : datafactory_name
                                                }                                                
                                            }
                                        ]
                                        title :  'Count Failed activity runs metrics for ${var.datafactory_name}' 
                                        titleKind : 1
                                        visualization : {
                                            chartType : 2
                                            legendVisualization : {
                                                isVisible : true
                                                position : 2
                                                hideSubtitle : false
                                            }
                                            axisVisualization : {
                                                x : {
                                                    isVisible : true
                                                    axisType : 2
                                                }
                                                y : {
                                                    isVisible : true
                                                    axisType : 1
                                                }
                                            }
                                            disablePinning : true
                                        }
                                    }
                                }
                            }
                        }            
                    }
                ]
            }
        ]
    }
  DASH
}
