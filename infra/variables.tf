variable "resource_group_name" {
  type = string
  description = "Name of the resource group"
}

variable "location" {
  type = string
  description = "Azure region to deploy resources"
  default = "East US"
}

variable "vnet_address_space" {
  type = list(string)
  description = "Address space for the virtual network"
  default = ["10.0.0.0/16"]
}

variable "subnet_address_prefixes" {
  type = list(string)
  description = "Address prefixes for the subnet"
  default = ["10.0.1.0/24"]
}

variable "app_service_plan_sku_tier" {
  type = string
  description = "Tier for the app service plan"
  default = "Standard"
}

variable "app_service_plan_sku_size" {
  type = string
  description = "Size for the app service plan"
  default = "S1"
}

variable "storage_account_replication_type" {
  type = string
  description = "Replication type for the storage account"
  default = "LRS"
}

variable "storage_account_tier" {
  type = string
  description = "Tier for the storage account"
  default = "Standard"
}

variable "automation_account_sku_name" {
  type = string
  description = "SKU name for the automation account"
  default = "Basic"
}

variable "key_vault_sku_name" {
  type = string
  description = "SKU name for the key vault"
  default = "standard"
}

variable "search_service_sku_name" {
  type = string
  description = "SKU name for the search service"
  default = "standard"
}

variable "search_service_sku_capacity" {
  type = number
  description = "Capacity for the search service"
  default = 1
}

variable "managed_rule_set_type" {
  type = string
  description = "Type of the managed rule set"
  default = "OWASP"
}

variable "managed_rule_set_version" {
  type = string
  description = "Version of the managed rule set"
  default = "3.2"
}

variable "email_address" {
  type = string
  description = "Email address for notifications"
}

//variable "runbook1_uri" {
//  type = string
//  description = "URI for the first runbook content"
//}


variable "search_service_partition_count" {

  description = "The number of partitions for the Azure Search Service."

  type        = number

  default     = 1

}

variable "content_filters" {
  type = map(object({
    mode           = string
    basePolicyName = string
    type           = string
    contentFilters = list(object({
      name                = string
      blocking            = bool
      enabled             = bool
      allowedContentLevel = string
      source              = string
    }))
  }))
  default = {
 "Block-High" = { 
   mode           = "Default"
   basePolicyName = "Microsoft.Default"
   type           = "UserManaged"
   contentFilters = [
     { name = "Hate", blocking = true, enabled = true, allowedContentLevel = "High", source = "Prompt" },
     { name = "Sexual", blocking = true, enabled = true, allowedContentLevel = "High", source = "Prompt" },
     { name = "selfharm", blocking = true, enabled = true, allowedContentLevel = "High", source = "Prompt" },
     { name = "Violence", blocking = true, enabled = true, allowedContentLevel = "High", source = "Prompt" },
     { name = "Hate", blocking = true, enabled = true, allowedContentLevel = "High", source = "Completion" },
     { name = "Sexual", blocking = true, enabled = true, allowedContentLevel = "High", source = "Completion" },
     { name = "selfharm", blocking = true, enabled = true, allowedContentLevel = "High", source = "Completion" },
     { name = "Violence", blocking = true, enabled = true, allowedContentLevel = "High", source = "Completion" }
   ]
 },
 "Block-Medium" = { 
   mode           = "Default"
   basePolicyName = "Microsoft.Default"
   type           = "UserManaged"
   contentFilters = [
     { name = "Hate", blocking = true, enabled = true, allowedContentLevel = "Medium", source = "Prompt" },
     { name = "Sexual", blocking = true, enabled = true, allowedContentLevel = "Medium", source = "Prompt" },
     { name = "selfharm", blocking = true, enabled = true, allowedContentLevel = "Medium", source = "Prompt" },
     { name = "Violence", blocking = true, enabled = true, allowedContentLevel = "Medium", source = "Prompt" },
     { name = "Hate", blocking = true, enabled = true, allowedContentLevel = "Medium", source = "Completion" },
     { name = "Sexual", blocking = true, enabled = true, allowedContentLevel = "Medium", source = "Completion" },
     { name = "selfharm", blocking = true, enabled = true, allowedContentLevel = "Medium", source = "Completion" },
     { name = "Violence", blocking = true, enabled = true, allowedContentLevel = "Medium", source = "Completion" }
   ]
 },
    "Allow-All" = {
      mode           = "Default" 
      basePolicyName = "Microsoft.Default" 
      type           = "UserManaged"
      contentFilters = [] # Empty list to effectively allow all content
    }
  }
}

variable "models" {
  type = map(object({
    model_format       = string
    model_name         = string
    model_version      = string
    rai_policy_name    = string # To associate with a content filter
    scale_type        = string
    scale_capacity     = number 
  }))
  default = {
    "gpt-4o-mini-deployment" = {
      model_format    = "OpenAI"
      model_name      = "gpt-4o-mini"
      model_version   = "2024-07-18"
      rai_policy_name = "Block-High"  # Reference a key from content_filters
      scale_type     = "Standard"
      scale_capacity  = 1
    },
    # ... (Add more models here)
    "Dall-e-3" = {
      model_format    = "OpenAI"
      model_name      = "dall-e-3"
      model_version   = "3.0"
      rai_policy_name = "Allow-All"  # Reference a key from content_filters
      scale_type     = "Standard"
      scale_capacity  = 1
    },

    "gpt-35-turbo" = {
      model_format    = "OpenAI"
      model_name      = "gpt-35-turbo"
      model_version   = "0125"
      rai_policy_name = "Allow-All"  # Reference a key from content_filters
      scale_type     = "Standard"
      scale_capacity  = 1
    },
  }
}