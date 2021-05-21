project           = "azureapi"
environment       = "dev"
location          = "UK West"
failover_location = "North Central US"
// below values should be manually populated to providers.tf file in case of update
resource_group  = "dev-storage-resource-group"
storage_account = "devazurestorageaccount"