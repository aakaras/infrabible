output "resource_group_name" {
  value = azurerm_resource_group.rg.name
}

output "app_service_url" {
  value = "https://${azurerm_app_service.appservice.default_site_hostname}"
}

output "azurerm_storage_account" {
  value = azurerm_storage_account.storage.name
}