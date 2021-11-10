# ---------------------------------------------------------------------------------------------------------------------
# Creating Azure Container Registry
# ---------------------------------------------------------------------------------------------------------------------

resource "azurerm_container_registry" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = var.sku

  identity {
    type = "SystemAssigned"
  }
}
