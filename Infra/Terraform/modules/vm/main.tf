resource "azurerm_linux_virtual_machine" "vm" {
  name                = "jenkins-vm"
  resource_group_name = var.rg_name
  location            = var.location
  size                = "Standard_D4as_v4"

  admin_username = "azureuser"

  network_interface_ids = [
    var.nic_id
  ]

  admin_ssh_key {
    username   = "azureuser"
    public_key = file("C:/Users/HP/.ssh/id_ed25519.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}
