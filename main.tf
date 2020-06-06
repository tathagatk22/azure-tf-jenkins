provider "azurerm" {
  subscription_id = "${var.subscription_id}"
  client_id       = "${var.client_id}"
  client_secret   = "${var.client_secret}"
  tenant_id       = "${var.tenant_id}"
  features {}
}


resource "azurerm_resource_group" "resource_group" {
  name     = "${var.resourceGroupName}"
  location = "${var.regionName}"
}

resource "azurerm_virtual_network" "virtual_network" {
  name                = "${var.resourceGroupName}_Vnet"
  address_space       = ["10.0.0.0/16"]
  location            = "${var.regionName}"
  resource_group_name = "${azurerm_resource_group.resource_group.name}"
}

resource "azurerm_subnet" "virtual_sub_network" {
  name                 = "${var.resourceGroupName}_Subnet"
  resource_group_name  = "${azurerm_resource_group.resource_group.name}"
  virtual_network_name = "${azurerm_virtual_network.virtual_network.name}"
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_public_ip" "public_ip" {
  name                = "${var.resourceGroupName}_PublicIP"
  location            = "${var.regionName}"
  resource_group_name = "${azurerm_resource_group.resource_group.name}"
  allocation_method   = "Dynamic"

}
resource "azurerm_network_interface" "nic" {
  name                = "${var.resourceGroupName}_NIC"
  location            = "${var.regionName}"
  resource_group_name = "${azurerm_resource_group.resource_group.name}"
  ip_configuration {
    name                          = "nic"
    subnet_id                     = "${azurerm_subnet.virtual_sub_network.id}"
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = "${azurerm_public_ip.public_ip.id}"
  }
}
resource "azurerm_network_security_group" "network_group" {
  name                = "${var.resourceGroupName}_NetworkSecurityGroup"
  location            = "${var.regionName}"
  resource_group_name = "${azurerm_resource_group.resource_group.name}"
}

resource "azurerm_network_security_rule" "port_for_SSH" {
  name                        = "SSH"
  priority                    = 1001
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = "${azurerm_resource_group.resource_group.name}"
  network_security_group_name = "${azurerm_network_security_group.network_group.name}"
}

resource "azurerm_network_security_rule" "port_for_jenkins" {
  name                        = "Jenkins_Port"
  priority                    = 2001
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = "${azurerm_resource_group.resource_group.name}"
  network_security_group_name = "${azurerm_network_security_group.network_group.name}"
}



# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "nic_ng_association" {
  network_interface_id      = "${azurerm_network_interface.nic.id}"
  network_security_group_id = "${azurerm_network_security_group.network_group.id}"
}

resource "azurerm_linux_virtual_machine" "virtual_machine" {
  name                  = "jenkinsVM"
  location              = "eastus"
  resource_group_name   = "${azurerm_resource_group.resource_group.name}"
  network_interface_ids = ["${azurerm_network_interface.nic.id}"]
  size                  = "${var.node_type}"

  os_disk {
    name                 = "jenkinsVMDisk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  admin_username                  = "${var.username}"
  admin_password                  = "${var.password}"
  disable_password_authentication = false
}
