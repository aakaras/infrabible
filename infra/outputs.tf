# output.tf
output "resource_group_name" {
  value = azurerm_resource_group.rg.name
}

output "app_service_url" {
  value = "https://${azurerm_app_service.appservice.default_site_hostname}"
}

output "azurerm_storage_account" {
  value = azurerm_storage_account.storage.name
}

output "cognitive_account_endpoint" {
  value = azurerm_cognitive_account.account.endpoint
}

output "cognitive_account_api_key" {
  value     = azurerm_cognitive_account.account.primary_access_key
  sensitive = true
}

output "search_api_key" {
  value     = azurerm_search_service.search.primary_key
  sensitive = true
}

output "search_endpoint" {
  description = "URL of the Search Service."
  value       = "https://search-${var.resource_group_name}.search.windows.net"
}

output "search_index" {
  description = "Search index name."
  value       = local.search_index_json.name
}