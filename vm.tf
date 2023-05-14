resource "azurerm_public_ip" "ip-example-cloud" {
  name                = "ip-example-cloud"
  resource_group_name = azurerm_resource_group.rg-example-cloud.name
  location            = azurerm_resource_group.rg-example-cloud.location
  allocation_method   = "Static"

  tags = {
    environment = "Production"
  }
}

resource "azurerm_network_interface" "nic-example-cloud" {
  name                = "nic-example-cloud"
  location            = azurerm_resource_group.rg-example-cloud.location
  resource_group_name = azurerm_resource_group.rg-example-cloud.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.sub-example-cloud.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.ip-example-cloud.id
  }
}

resource "azurerm_linux_virtual_machine" "vm-example-cloud" {
  name                            = "vm-example-cloud"
  resource_group_name             = azurerm_resource_group.rg-example-cloud.name
  location                        = azurerm_resource_group.rg-example-cloud.location
  size                            = "Standard_DS1_v2"
  admin_username                  = "adminuser"
  admin_password                  = "Teste@1234!"
  disable_password_authentication = false
  network_interface_ids = [
    azurerm_network_interface.nic-example-cloud.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}

resource "azurerm_network_interface_security_group_association" "nic-nsg-example-cloud" {
  network_interface_id      = azurerm_network_interface.nic-example-cloud.id
  network_security_group_id = azurerm_network_security_group.nsg-example-cloud.id
}


resource "null_resource" "install-nginx" {
    connection {
     type = "ssh"
     host = azurerm_public_ip.ip-example-cloud.ip_address
     user = "adminuser"
     password = "Teste@1234!"
    }

    provisioner "remote-exec" {
      inline = [
      "sudo apt update", 
      "sudo apt install -y nginx" 
      ]
    }
    depends_on = [ azurerm_linux_virtual_machine.vm-example-cloud ]
}