terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0" # Use the latest version compatible with your environment
    }
    azapi = {
      source  = "Azure/azapi"
      version = "~> 1.0"
    }

  }
}

provider "azurerm" {
  features {}
}

# Declare the azurerm_client_config data resource
data "azurerm_client_config" "current" {}

# --- 1. Resource Group (no dependencies) ---
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
  tags     = local.common_tags
}

# --- 2. Virtual Network (depends on resource group) ---
resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-${local.base_name}" 
  address_space       = var.vnet_address_space
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  tags                = local.common_tags
}

# --- 3. Subnet (depends on virtual network) ---
resource "azurerm_subnet" "subnet" {
  name                 = "subnet-${local.base_name}" 
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = var.subnet_address_prefixes
}

# --- 4. Public IP (depends on resource group) ---
resource "azurerm_public_ip" "public_ip" {
  name                = "public-ip-${local.base_name}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = local.common_tags
}

# --- Resources without explicit dependencies (can run in parallel after RG) ---

resource "azurerm_storage_account" "storage" {
  name                     = format("%sx%s", replace(local.base_name, "-", ""),"fileupload")
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = var.storage_account_tier
  account_replication_type = var.storage_account_replication_type
  tags                     = local.common_tags
}

resource "azurerm_automation_account" "automation" {
  name                = "aa-${local.base_name}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku_name            = var.automation_account_sku_name
  tags                = local.common_tags
}

resource "azurerm_key_vault" "kv" {
  name                = "kv-${local.base_name}-swd" 
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku_name            = var.key_vault_sku_name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  tags                = local.common_tags
}

resource "azurerm_application_insights" "appinsights" {
  name                = "appi-${local.base_name}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  application_type    = "web"
  tags                = local.common_tags
}

resource "azurerm_dns_zone" "dnszone" {
  name                = "genaidemo.tech" 
  resource_group_name = azurerm_resource_group.rg.name
  tags                = local.common_tags
}

# --- Resources that depend on others ---

resource "azurerm_app_service_plan" "asp" {
  name                = "ASP-${local.base_name}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku {
    tier = var.app_service_plan_sku_tier
    size = var.app_service_plan_sku_size
  }
  timeouts { 
    delete = "15m" # Adjust as needed based on observed deletion times 
  }
  tags = local.common_tags
}

resource "azurerm_app_service" "appservice" {
  name                = "APP-${local.base_name}-swd"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  app_service_plan_id = azurerm_app_service_plan.asp.id # Depends on app service plan
  app_settings = {
    "APPINSIGHTS_INSTRUMENTATIONKEY" = azurerm_application_insights.appinsights.instrumentation_key 
  }
  tags = local.common_tags
}

resource "azurerm_search_service" "search" {
  name                = "search-${local.base_name}" # Using a naming convention
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = var.search_service_sku_name
  replica_count       = var.search_service_sku_capacity
  partition_count     = var.search_service_partition_count
  tags                = local.common_tags
}

resource "azurerm_application_gateway" "appgw" {
  name                = "appgw-${local.base_name}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 2
  }
  gateway_ip_configuration {
    name      = "appgwIpConfig"
    subnet_id = azurerm_subnet.subnet.id # Depends on subnet
  }
  frontend_ip_configuration {
    name                 = "appgwFrontendIp"
    public_ip_address_id = azurerm_public_ip.public_ip.id # Depends on public IP 
  }
  frontend_port {
    name = "frontendPort"
    port = 80
  }
  backend_address_pool {
    name = "backendPool"
  }
  backend_http_settings {
    name                  = "httpSettings"
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 20
  }
  http_listener {
    name                           = "httpListener"
    frontend_ip_configuration_name = "appgwFrontendIp"
    frontend_port_name             = "frontendPort"
    protocol                       = "Http"
  }
  request_routing_rule {
    name                       = "routingRule"
    rule_type                  = "Basic"
    http_listener_name         = "httpListener"
    backend_address_pool_name  = "backendPool"
    backend_http_settings_name = "httpSettings"
    priority                   = 100
  }
  tags = local.common_tags
}

# --- Monitor Action Group (no explicit dependencies) ---
resource "azurerm_monitor_action_group" "action_group" {
  name                = "AISD-${local.base_name}"
  resource_group_name = azurerm_resource_group.rg.name
  short_name          = "AISD"
  email_receiver {
    name          = "default"
    email_address = var.email_address
  }
  tags = local.common_tags
}

resource "azurerm_cognitive_account" "account" {
  name                = "${local.base_name}-azoai"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  kind                = "OpenAI"
  sku_name            = "S0"
  #depends_on = [azapi_resource.content_filters]
}


resource "azapi_resource" "content_filters" {
  for_each = var.content_filters

  name                      = each.key
  type                      = "Microsoft.CognitiveServices/accounts/raiPolicies@2023-10-01-preview"
  parent_id                 = azurerm_cognitive_account.account.id
  schema_validation_enabled = false
  body = jsonencode({
  properties = each.value
  })
  depends_on = [azurerm_cognitive_account.account]

}

resource "azurerm_cognitive_deployment" "deployments" {
  for_each = var.models

  name                 = each.key 
  cognitive_account_id = azurerm_cognitive_account.account.id
  rai_policy_name      = each.value.rai_policy_name # Associate with desired policy
  model {
    format  = each.value.model_format 
    name    = each.value.model_name
    version = each.value.model_version
  }
  scale {
    type     = each.value.scale_type 
    capacity = each.value.scale_capacity 
  }
  lifecycle {
    create_before_destroy = true
    ignore_changes = [
      model,
    ]
  }
  # Ensure deployments are deleted before content filters to avoid dependency issues
  #depends_on = [azapi_resource.content_filters] 
}

resource "azurerm_key_vault_access_policy" "access_policy" {
  key_vault_id = azurerm_key_vault.kv.id

  tenant_id = data.azurerm_client_config.current.tenant_id
  object_id = data.azurerm_client_config.current.object_id

  secret_permissions = [
    "Get",
    "List",
    "Set",
    "Delete",
    "Recover",
    "Backup",
    "Restore",
    "Purge"
  ]
}

resource "azurerm_key_vault_secret" "cognitive_endpoint" {
  name         = "AZURE-OPENAI-ENDPOINT" # Choose a descriptive name
  value        = azurerm_cognitive_account.account.endpoint
  key_vault_id = azurerm_key_vault.kv.id

  
  depends_on = [
    azurerm_key_vault_access_policy.access_policy
  ]
}

resource "azurerm_key_vault_secret" "cognitive_api_key" {
  name         = "AZURE-OPENAI-KEY" # Choose a descriptive name
  value        = azurerm_cognitive_account.account.primary_access_key
  key_vault_id = azurerm_key_vault.kv.id

  depends_on = [
    azurerm_key_vault_access_policy.access_policy
  ]
}

resource "azurerm_key_vault_secret" "search_key" {
  name         = "SEARCH-KEY" # Choose a descriptive name
  value        = azurerm_search_service.search.primary_key
  key_vault_id = azurerm_key_vault.kv.id

  depends_on = [
    azurerm_key_vault_access_policy.access_policy
  ]
}

resource "azurerm_key_vault_secret" "search_url" {
  name         = "AZURE-SEARCH-ENDPOINT" # Choose a descriptive name
  value        = "https://search-${local.base_name}.search.windows.net"
  key_vault_id = azurerm_key_vault.kv.id

  depends_on = [
    azurerm_key_vault_access_policy.access_policy
  ]
}