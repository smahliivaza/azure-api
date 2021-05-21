resource "azurerm_app_service_plan" "app_service_plan" {
  name                = "${var.project}-${var.environment}-app-service-plan"
  resource_group_name = azurerm_resource_group.resource_group.name
  location            = var.location
  kind                = "FunctionApp"
  reserved            = true
  sku {
    tier = "Dynamic"
    size = "Y1"
  }
}

resource "azurerm_function_app" "function_app" {
  name                       = "${var.project}-${var.environment}-function-app"
  resource_group_name        = azurerm_resource_group.resource_group.name
  location                   = var.location
  app_service_plan_id        = azurerm_app_service_plan.app_service_plan.id
  storage_account_name       = azurerm_storage_account.storage_account.name
  storage_account_access_key = azurerm_storage_account.storage_account.primary_access_key
  os_type                    = "linux"
  version                    = "~3"
  app_settings = {
    "WEBSITE_RUN_FROM_PACKAGE"       = "",
    "FUNCTIONS_WORKER_RUNTIME"       = "python",
    "APPINSIGHTS_INSTRUMENTATIONKEY" = azurerm_application_insights.application_insights.instrumentation_key,
    "COSMOSDB_ENDPOINTURI"           = azurerm_cosmosdb_account.account.endpoint,
    "COSMOSDB_PRIMARYKEY"            = azurerm_cosmosdb_account.account.primary_master_key,
  }
  site_config {
    linux_fx_version          = "PYTHON|3.8"
    use_32_bit_worker_process = false
  }

  identity {
    type = "SystemAssigned"
  }

  lifecycle {
    ignore_changes = [
      app_settings["WEBSITE_RUN_FROM_PACKAGE"],
    ]
  }
  depends_on = [
    azurerm_cosmosdb_account.account,
  ]
}

resource "null_resource" "functions" {
  triggers = {
    functions = "${local.version}_${join("+", [for value in local.functions : value["name"]])}"
  }

  provisioner "local-exec" {
    command = "cd ../azure-functions; func azure functionapp publish ${azurerm_function_app.function_app.name} --build remote; cd ../infrastructure"
  }
}

locals {
  version   = yamldecode(file("../config.yml"))["version"]
  functions = yamldecode(file("../config.yml"))["functions"]
}
