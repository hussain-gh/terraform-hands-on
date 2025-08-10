resource "azurerm_resource_group" "this" {
  name     = "${var.project}-${var.environment}-${var.type}-rg"
  location = var.location
}
