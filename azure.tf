variable "subscription_id" {
  description = "Azure subscription ID"
  default     = "SUBSCRIPTION_ID"
}
variable "client_id" {
  description = "Azure client ID"
  default     = "CLIENT_ID"
}
variable "client_secret" {
  description = "Azure client secret"
  default     = "CLIENT_SECRET"
}
variable "tenant_id" {
  description = "Azure tenant ID"
  default     = "TENANT_ID"
}

# Configure the Azure Resource Manager Provider
provider "azurerm" {
  subscription_id = "${var.subscription_id}"
  client_id       = "${var.client_id}"
  client_secret   = "${var.client_secret}"
  tenant_id       = "${var.tenant_id}"
}

# Create a resource group
resource "azurerm_resource_group" "test" {
  name     = "Terraform"
  location = "West US"
}

resource "azurerm_virtual_network" "test" {
  name                = "TestTerraformVirtualNetwork"
  resource_group_name = "${azurerm_resource_group.test.name}"
  address_space       = ["10.0.0.0/16"]
  location            = "West US"
  dns_servers         = ["10.0.0.4", "10.0.0.5"]

  subnet {
    name           = "subnet1"
    address_prefix = "10.0.1.0/24"
  }
  subnet {
    name           = "subnet2"
    address_prefix = "10.0.2.0/24"
  }
  subnet {
    name           = "subnet3"
    address_prefix = "10.0.3.0/24"
  }
  tags {
    environment = "test"
  }
}
