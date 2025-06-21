// Log Analytics Workspace
resource "azurerm_log_analytics_workspace" "this" {
  name                = var.workspace_name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags                = var.tags
}

// Action Group for alert notifications
resource "azurerm_monitor_action_group" "this" {
  name                = var.action_group_name
  resource_group_name = var.resource_group_name
  short_name          = var.action_group_name

  email_receiver {
    name          = "adminEmail"
    email_address = var.email
  }

  tags = var.tags
}

// Diagnostic Settings for key resources
resource "azurerm_monitor_diagnostic_setting" "ds" {
  for_each                   = { for resource in var.monitored_resources : resource.name => resource }
  name                       = each.value.name
  target_resource_id         = each.value.target_resource_id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.this.id

  enabled_log {
    category = "AllLogs"
  }

  enabled_metric {
    category = "AllMetrics"
  }
}

// Metric Alerts
resource "azurerm_monitor_metric_alert" "alert" {
  for_each            = { for rule in var.alert_rules : rule.name => rule }
  name                = each.value.name
  resource_group_name = var.resource_group_name
  scopes              = [each.value.target_resource_id]
  description         = "Alert for ${each.value.metric_name}"
  frequency           = "PT1M"
  severity            = each.value.severity
  window_size         = "PT5M"

  criteria {
    metric_namespace = each.value.metric_namespace
    metric_name      = each.value.metric_name
    aggregation      = each.value.aggregation
    operator         = each.value.operator
    threshold        = each.value.threshold
  }

  action {
    action_group_id = azurerm_monitor_action_group.this.id
  }

  tags = var.tags
}