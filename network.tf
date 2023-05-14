resource "azurerm_virtual_network" "vnet-example-cloud" {
  name                = "vnet-example-cloud"
  location            = azurerm_resource_group.rg-example-cloud.location
  resource_group_name = azurerm_resource_group.rg-example-cloud.name
  address_space       = ["10.0.0.0/16"]

  tags = {
    environment = "Production"
    faculdade   = "Impacta"
  }
}

resource "azurerm_subnet" "sub-example-cloud" {
  name                 = "sub-example-cloud"
  resource_group_name  = azurerm_resource_group.rg-example-cloud.name
  virtual_network_name = azurerm_virtual_network.vnet-example-cloud.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_security_group" "nsg-example-cloud" {
  name                = "nsg-example-cloud"
  location            = azurerm_resource_group.rg-example-cloud.location
  resource_group_name = azurerm_resource_group.rg-example-cloud.name

  security_rule {
    name                       = "SSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Web"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    environment = "Production"
  }
}