terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.0.1"
    }
  }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
  subscription_id = var.azure_sbuscription_id

}

resource "azurerm_resource_group" "rg" {
  name     = "demo-rg"
  location = "${var.rg-location}"
  tags = {
    environment = "${var.env}"
  }
}

resource "azurerm_virtual_network" "demo-vn" {
  name                = "demo-vn"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  address_space       = ["10.123.0.0/16"]

  tags = {
    environment = "${var.env}"
  }
}


resource "azurerm_subnet" "demo-subnet" {
  name                 = "demo-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.demo-vn.name

  address_prefixes = ["10.123.1.0/24"]
}

resource "azurerm_network_security_group" "demo-sg" {
  name                = "demo-sg"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location


  tags = {
    environment = "${var.env}"
  }
}

resource "azurerm_network_security_rule" "rule1" {
  name                        = "rule1"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.demo-sg.name
}

resource "azurerm_subnet_network_security_group_association" "demo-sga" {
  subnet_id                 = azurerm_subnet.demo-subnet.id
  network_security_group_id = azurerm_network_security_group.demo-sg.id
}

resource "azurerm_public_ip" "demo-pip" {
  name                = "demo-pip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Dynamic"
  sku                 = "Basic" # Change SKU to Basic

  tags = {
    environment = "${var.env}"
  }

}

resource "azurerm_network_interface" "demo-ni" {
  name                = "demo-ni"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.demo-subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.demo-pip.id

  }
  tags = {
    environment = "${var.env}"
  }
}

resource "azurerm_linux_virtual_machine" "demo-vm" {
  name                = "demo-vm"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_B1s"
  admin_username      = "mehdi"

  custom_data = filebase64("customdata.tpl")
  
  network_interface_ids = [
    azurerm_network_interface.demo-ni.id,
  ]
  tags = {
    environment = "${var.env}"
  }

  admin_ssh_key {
    username   = "${var.admin-user}"
    public_key = file("${var.ssh_file}.pub")
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

  provisioner "local-exec" {
    command = templatefile("${var.host_os}-ssh-script.tpl", {
      hostname     = self.public_ip_address
      user         = self.admin_username
      identityfile = "${var.ssh_file}"
    })
    interpreter = var.host_os == "linux" ? ["bash", "-c"] :["PowerShell", "-Command"]
  }

}
data "azurerm_public_ip" "ip-data" {
  name                = azurerm_public_ip.demo-pip.name
  resource_group_name = azurerm_resource_group.rg.name
}

output "public_ip_address" {
  value = "${azurerm_linux_virtual_machine.demo-vm.name}: ${data.azurerm_public_ip.ip-data.ip_address}"
}