data "azurerm_resource_group" "this" {
  name = var.resource_group_name
}

resource "azurerm_management_lock" "this" {
  name       = var.name
  scope      = data.azurerm_resource_group.this.id
  lock_level = "CanNotDelete"
}
