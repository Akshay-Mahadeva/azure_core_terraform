provider "azurerm" {
  features {

  }
}

locals {
  resource_group_name = "Cloudfoundation"
  location            = "eastus"
  retention_days      = "7"
  name                = "cloud-foundation" 
  tags = {
    environment = "production"
    deployment  = "Terraform"}
  }
 



data "azurerm_resource_group" "rg" {
  name = local.resource_group_name
}

# Azure active domain
module "azure_active_domain" {
  source = "./active_domain"
  address_space = []
  address_prefixes = []
  
}

# resource "random_string" "ran_name" {
#   length  = 4
#   upper   = false
#   special = false
# }

module "storage_module" {
  source               = ""
  location             = data.azurerm_resource_group.rg.location
  storage_account_name = "st-${local.name}"
  container_name       = "ct-${local.name}"
  blob_name            = "blob-${local.name}"
  resource_group_name  = data.azurerm_resource_group.rg.name

}

# #log analytics workspace
module "log_module" {
  source              = "git::https://akshay:iwhb64thiwvu5sgmbq4jopcyz46ejhgenvkfa5ijrrohr422abwq@dev.azure.com/ismiletechnologies/CloudAgnosticIaC/_git/azure_terraform_log_analytics_module"
  location            = data.azurerm_resource_group.rg.location
  name                = "log-core-${local.name}"
  solution_name       = "lga-${local.name}"
  resource_group_name = data.azurerm_resource_group.rg.name


  tags = local.tags
}

# #Keyvault working 
module "key_vault_module" {
  source = "git::https://akshay:iwhb64thiwvu5sgmbq4jopcyz46ejhgenvkfa5ijrrohr422abwq@dev.azure.com/ismiletechnologies/CloudAgnosticIaC/_git/azure_terraform_key_vault"

  # Resource Group Variables

  create_az_rg   = false
  az_rg_name     = local.resource_group_name
  az_rg_location = local.location

  # Key vault Variables 
  az_kv_name     = "kv-${local.name}" #once deployed name should be changed to a unique name otherwise t wont deploy
  az_kv_sku_name = "standard"

  az_kv_purge_protection_enabled   = false
  az_kv_soft_delete_enabled        = false
  az_kv_soft_delete_retention_days = 7


  az_net_acls = {
    bypass                     = "None"
    default_action             = "Deny"
    ip_rules                   = []
    virtual_network_subnet_ids = []
  }

  az_tags = local.tags

  # To enable logs for either storage account or eventhub turn to true.
  az_kv_ds_enable_logs_to_storage = false
  #az_kv_ds_storage_account_id     = module.az-storage-account-for-logs.az-sa-id

  az_kv_ds_enable_logs_to_eventhub = false
  #az_kv_ds_log_analytics_ws_id             = module.az-log-analytics.az-la-ws-id
}


  
