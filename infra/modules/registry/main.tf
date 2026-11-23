resource "azurerm_container_registry" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "Basic"
  admin_enabled       = true # TEMPORARY: replace with managed identity + AcrPull when role assignments are possible
  tags                = var.tags
}
