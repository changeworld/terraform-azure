variable "default_user" {}
variable "default_password" {}
variable "subscription_id" {}
variable "client_id" {}
variable "client_secret" {}
variable "tenant_id" {}
variable "account_count" {}

provider "azurerm" {
  subscription_id = "${var.subscription_id}"
  client_id       = "${var.client_id}"
  client_secret   = "${var.client_secret}"
  tenant_id       = "${var.tenant_id}"
}

resource "azurerm_resource_group" "test" {
  name     = "Terraform-WestUS-Test"
  location = "West US"
}

resource "azurerm_virtual_network" "test" {
  name                = "TestTerraformVirtualNetwork"
  address_space       = ["10.0.0.0/16"]
  location            = "West US"
  resource_group_name = "${azurerm_resource_group.test.name}"
}

resource "azurerm_subnet" "test" {
  name                 = "TestTerraformVirtualSubNetwork"
  resource_group_name  = "${azurerm_resource_group.test.name}"
  virtual_network_name = "${azurerm_virtual_network.test.name}"
  address_prefix       = "10.0.2.0/24"
}

resource "azurerm_public_ip" "test" {
  count                        = 2
  name                         = "${format("TerraformIP%02d", count.index + 1)}"
  location                     = "West US"
  resource_group_name          = "${azurerm_resource_group.test.name}"
  public_ip_address_allocation = "static"
  tags {
    environment = "test"
  }
}

resource "azurerm_network_interface" "test" {
  count               = 2
  name                = "${format("TestTerraformNetworkIF%02d", count.index + 1)}"
  location            = "West US"
  resource_group_name = "${azurerm_resource_group.test.name}"
  ip_configuration {
    name                          = "TestTerraformConfiguration"
    subnet_id                     = "${azurerm_subnet.test.id}"
    private_ip_address_allocation = "dynamic"
    public_ip_address_id          = "${element(azurerm_public_ip.test.*.id, count.index)}"
  }
}

resource "azurerm_storage_account" "test" {
  name                = "test4terraform${var.account_count}"
  resource_group_name = "${azurerm_resource_group.test.name}"
  location            = "westus"
  account_type        = "Standard_LRS"
  tags {
    environment = "test"
  }
}

resource "azurerm_storage_container" "test" {
  count                 = 2
  name                  = "${format("test4terraformcontainer%02d", count.index + 1)}"
  resource_group_name   = "${azurerm_resource_group.test.name}"
  storage_account_name  = "${azurerm_storage_account.test.name}"
  container_access_type = "private"
}

resource "azurerm_virtual_machine" "test" {
  count                 = 2
  name                  = "${format("TestTerraformVirtualMachine%02d", count.index + 1)}"
  location              = "West US"
  resource_group_name   = "${azurerm_resource_group.test.name}"
  network_interface_ids = ["${element(azurerm_network_interface.test.*.id, count.index)}"]
  vm_size               = "Standard_A0"
  storage_image_reference {
    publisher = "CoreOS"
    offer     = "CoreOS"
    sku       = "Stable"
    version   = "latest"
  }
  storage_os_disk {
    name          = "TestTerraformStorageOSDisk"
    vhd_uri       = "${azurerm_storage_account.test.primary_blob_endpoint}${element(azurerm_storage_container.test.*.name, count.index)}/myosdisk1.vhd"
    caching       = "ReadWrite"
    create_option = "FromImage"
  }
  os_profile {
    computer_name  = "TestTerraform"
    admin_username = "${var.default_user}"
    admin_password = "${var.default_password}"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  provisioner "remote-exec" {
    connection {
      type     = "ssh"
      user     = "${var.default_user}"
      password = "${var.default_password}"
      host     = "${element(azurerm_public_ip.test.*.ip_address, count.index)}"
    }
    inline = [
      "echo ${var.default_password} | sudo -S docker run hello-world"
    ]
  }
  tags {
    environment = "test"
  }
}
