provider "azurerm" {
  subscription_id = "1eb47ed1-c3a9-4369-87e3-43881d9fb93f"
  client_id       = "b13d706a-ec6c-4231-a35c-9bd4713e74b7"
  client_secret   = "zJFikn3fQb25yNfUqAEPhybhbaF4HGUQciAQgqkXSUc="
  tenant_id       = "4a7c8238-5799-4b16-9fc6-9ad8fce5a7d9"
}

resource "azurerm_resource_group" "tf-rg" {
  name     = "RG-Terraform"
  location = "North Europe"
}

resource "azurerm_virtual_network" "tf-vnet" {
  name                = "tf-virtualNetwork1"
  location            = "${azurerm_resource_group.tf-rg.location}"
  resource_group_name = "${azurerm_resource_group.tf-rg.name}"
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "tf-subnet-1" {
  name                      = "tf-subnet1"
  resource_group_name       = "${azurerm_resource_group.tf-rg.name}"
  virtual_network_name      = "${azurerm_virtual_network.tf-vnet.name}"
  address_prefix            = "10.0.1.0/24"
  network_security_group_id = "${azurerm_network_security_group.tf-nsg1.id}"
}

resource "azurerm_network_security_group" "tf-nsg1" {
  name                = "tf-nsg1"
  location            = "North Europe"
  resource_group_name = "${azurerm_resource_group.tf-rg.name}"

  security_rule {
    name                       = "rule-1"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface" "tf-nic-1" {
  name                = "tf-nic-1"
  resource_group_name = "${azurerm_resource_group.tf-rg.name}"
  location            = "${azurerm_resource_group.tf-rg.location}"

  ip_configuration {
    name                          = "config-tf-nic-1"
    subnet_id                     = "${azurerm_subnet.tf-subnet-1.id}"
    private_ip_address_allocation = "dynamic"
    public_ip_address_id          = "${azurerm_public_ip.tf-pip-1.id}"
  }
}

resource "azurerm_public_ip" "tf-pip-1" {
  name                         = "tf-pip-1"
  resource_group_name          = "${azurerm_resource_group.tf-rg.name}"
  public_ip_address_allocation = "static"
  location                     = "${azurerm_resource_group.tf-rg.location}"
}

resource "azurerm_storage_account" "tf-sg-1" {
  name                = "tf0sg01"
  resource_group_name = "${azurerm_resource_group.tf-rg.name}"
  location            = "${azurerm_resource_group.tf-rg.location}"
  account_type        = "Standard_GRS"
}

resource "azurerm_storage_container" "tf-storage-container" {
  name                  = "tf-storage-container"
  resource_group_name   = "${azurerm_resource_group.tf-rg.name}"
  storage_account_name  = "${azurerm_storage_account.tf-sg-1.name}"
  container_access_type = "private"
}
