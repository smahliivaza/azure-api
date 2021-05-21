resource "azurerm_resource_group" "resource_group" {
  name     = var.resource_group
  location = var.location
}

resource "azurerm_storage_account" "storage_account" {
  name                     = var.storage_account
  resource_group_name      = azurerm_resource_group.resource_group.name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "RAGRS"
}

resource "azurerm_application_insights" "application_insights" {
  name                = "${var.project}-${var.environment}-application-insights"
  location            = var.location
  resource_group_name = azurerm_resource_group.resource_group.name
  application_type    = "other"
}
