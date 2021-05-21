resource "azurerm_cosmosdb_account" "account" {
  name                      = "${var.project}-${var.environment}-cosmos-account"
  location                  = var.location
  resource_group_name       = azurerm_resource_group.resource_group.name
  offer_type                = "Standard"
  kind                      = "GlobalDocumentDB"
  enable_automatic_failover = true
  consistency_policy {
    consistency_level = "Session"
  }
  geo_location {
    location          = var.failover_location
    failover_priority = 1
  }
  geo_location {
    location          = var.location
    failover_priority = 0
  }
}

resource "azurerm_cosmosdb_sql_database" "db" {
  name                = "library"
  resource_group_name = azurerm_resource_group.resource_group.name
  account_name        = azurerm_cosmosdb_account.account.name
}

resource "azurerm_cosmosdb_sql_container" "books_collection" {
  name                = "books"
  resource_group_name = azurerm_resource_group.resource_group.name
  account_name        = azurerm_cosmosdb_account.account.name
  database_name       = azurerm_cosmosdb_sql_database.db.name
  partition_key_path  = "/id"
}

resource "azurerm_cosmosdb_sql_container" "categories_collection" {
  name                = "categories"
  resource_group_name = azurerm_resource_group.resource_group.name
  account_name        = azurerm_cosmosdb_account.account.name
  database_name       = azurerm_cosmosdb_sql_database.db.name
  partition_key_path  = "/Category"
}
