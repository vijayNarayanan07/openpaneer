mock_provider "azurerm" {
  mock_resource "azurerm_postgresql_flexible_server" {
    defaults = {
      id   = "/subscriptions/12345678-1234-9876-4563-123456789012/resourceGroups/rg-mock/providers/Microsoft.DBforPostgreSQL/flexibleServers/psql-mock"
      fqdn = "psql-mock.postgres.database.azure.com"
    }
  }

  mock_resource "azurerm_service_plan" {
    defaults = {
      id = "/subscriptions/12345678-1234-9876-4563-123456789012/resourceGroups/rg-mock/providers/Microsoft.Web/serverFarms/asp-mock"
    }
  }
}

run "dev_preview" {
  command = plan
}
