# Define the Azure provider and authentication details
provider "azurerm" {
  features {}
}


# Create the resource group
resource "azurerm_resource_group" "example_rg" {
  name     = "example-resource-group"
  location = "West Europe"
}

# Create the virtual network
resource "azurerm_virtual_network" "example_vnet" {
  name                = "example-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.example_rg.location
  resource_group_name = azurerm_resource_group.example_rg.name
}

# Create the subnet within the virtual network
resource "azurerm_subnet" "example_subnet" {
  name                 = "example-subnet"
  resource_group_name  = azurerm_resource_group.example_rg.name
  virtual_network_name = azurerm_virtual_network.example_vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Create the network interface card
resource "azurerm_network_interface" "example_nic" {
  name                = "example-nic"
  location            = azurerm_resource_group.example_rg.location
  resource_group_name = azurerm_resource_group.example_rg.name

  ip_configuration {
    name                          = "example-ip-config"
    subnet_id                     = azurerm_subnet.example_subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

# Create the Windows virtual machine
resource "azurerm_windows_virtual_machine" "example_vm" {
  name                  = "example-vm"
  resource_group_name   = azurerm_resource_group.example_rg.name
  location              = azurerm_resource_group.example_rg.location
  size                  = "Standard_DS2_v2"
  admin_username        = "adminuser"
  admin_password        = "Password1234!"
  network_interface_ids = [azurerm_network_interface.example_nic.id]
  os_disk {
    name              = "example-os-disk"
    caching           = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }
}
