locals {
  common_tags = {
 ResourceOwner = "Alison Karas"
 ExpireOn =  "2099-12-20"
  }
}

locals {
  base_name = substr(var.resource_group_name, 3, length(var.resource_group_name) - 3)
}