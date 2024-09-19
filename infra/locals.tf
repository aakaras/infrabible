# locals.tf
locals {
  common_tags = {
    ResourceOwner = "Alison Karas"
    ExpireOn      = "2099-12-20"
  }
  base_name = substr(var.resource_group_name, 3, length(var.resource_group_name) - 3)

  # Azure Search Index Definition 
  search_index_json = {
    name = "search-index"
    fields = [
      {
        name        = "id"
        type        = "Edm.String"
        key         = true
        retrievable = true
      },
      {
        name        = "content"
        type        = "Edm.String"
        searchable  = true
        retrievable = true
        filterable  = false
        facetable   = false
        sortable    = false
      },
      {
        name        = "title"
        type        = "Edm.String"
        searchable  = true
        retrievable = true
        filterable  = true
        facetable   = true
        sortable    = true
      },
      {
        name        = "created_at"
        type        = "Edm.DateTimeOffset"
        searchable  = false
        retrievable = true
        filterable  = true
        facetable   = true
        sortable    = true
      }
    ]
  }

  # Azure Search Data Source Definition
  search_datasource_json = {
    name        = "blob-datasource"
    description = "Data source for blob storage"
    type        = "azureblob"
    credentials = {
      connectionString = "DefaultEndpointsProtocol=https;AccountName=${azurerm_storage_account.storage.name};AccountKey=${azurerm_storage_account.storage.primary_access_key};EndpointSuffix=core.windows.net"
    }
    container = {
      name = azurerm_storage_container.search_container.name
    }
  }

  # Azure Search Indexer Definition
  search_indexer_json = {
    name            = "blob-indexer"
    dataSourceName  = local.search_datasource_json.name
    targetIndexName = local.search_index_json.name
  }
} 
