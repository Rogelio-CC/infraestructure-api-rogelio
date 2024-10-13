# Construir grupo de recursos con terraform
resource "azurerm_resource_group" "IN_RG" {
  name     = "${var.resourse_group}-${var.environment}"
  location = var.location
  tags = {
    "environment" = var.environment
  }
}

# Construir virtual network
resource "azurerm_virtual_network" "IN_VNET" {
  name                = "${var.vnet_name}-${var.environment}"
  resource_group_name = azurerm_resource_group.IN_RG.name
  location            = var.location
  address_space       = ["10.123.0.0/16"]
  tags = {
    "environment" : var.environment
  }
}
#Construir Subnet
resource "azurerm_subnet" "IN_SUBNET" {
  name                 = "${var.subnet_name}-${var.environment}"
  resource_group_name  = azurerm_resource_group.IN_RG.name
  virtual_network_name = azurerm_virtual_network.IN_VNET.name
  address_prefixes     = ["10.123.1.0/24"]
}

# Construir security groups
resource "azurerm_network_security_group" "IN_SG" {
  name                = var.security_group_name
  location            = var.location
  resource_group_name = azurerm_resource_group.IN_RG.name
  tags = {
    "environment" = var.environment
  }

  security_rule {
    name                       = "ssh-allow"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "http-allow"
    priority                   = 102
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "https-allow"
    priority                   = 103
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

}

# Crear asociacion entre subnet y security groups
resource "azurerm_subnet_network_security_group_association" "IN-SGA" {
  subnet_id                 = azurerm_subnet.IN_SUBNET.id
  network_security_group_id = azurerm_network_security_group.IN_SG.id
}

# Crear IP Publica
resource "azurerm_public_ip" "IN-IP" {
  name                = "${var.ip_name}-${var.environment}"
  resource_group_name = azurerm_resource_group.IN_RG.name
  location            = var.location
  allocation_method   = "Dynamic"
}

# Crear network interface
resource "azurerm_network_interface" "IN-NIC" {
  name                = var.nic_name
  location            = var.location
  resource_group_name = azurerm_resource_group.IN_RG.name

  ip_configuration {
    name                          = "${var.ip_name}-Config-${var.environment}"
    subnet_id                     = azurerm_subnet.IN_SUBNET.id
    public_ip_address_id          = azurerm_public_ip.IN-IP.id
    private_ip_address_allocation = "Dynamic"
  }

  tags = {
    "environment" = var.environment
  }
}

# Crear la maquina virtual
resource "azurerm_linux_virtual_machine" "IN-VM" {
  name                  = "${var.server_name}-${var.environment}"
  resource_group_name   = azurerm_resource_group.IN_RG.name
  location              = var.location
  size                  = "Standard_B2s"
  admin_username        = var.adminuser
  network_interface_ids = [azurerm_network_interface.IN-NIC.id]
  custom_data           = filebase64("${path.module}/scripts/docker-install.tpl")

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    version   = "latest"
    sku       = "22_04-lts"
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
  }

  admin_ssh_key {
    username   = var.adminuser
    public_key = file("${var.ssh_key_path}.pub")
  }

  provisioner "file" {
    source      = "./containers/docker-compose.yml"
    destination = "/home/${var.adminuser}/docker-compose.yml"

    connection {
      type        = "ssh"
      user        = var.adminuser
      private_key = file(var.ssh_key_path)
      host        = self.public_ip_address
    }
  }

  provisioner "remote-exec" {
    inline = [
      "sudo su -c 'mkdir -p /home/${var.adminuser}'",
      "sudo su -c 'mkdir -p /volumes/nginx/html'",
      "sudo su -c 'mkdir -p /volumes/nginx/certs'",
      "sudo su -c 'mkdir -p /volumes/nginx/vhostd'",
      "sudo su -c 'mkdir -p /volumes/mongo/data'",
      "sudo su -c 'chmod -R 770 /volumes/mongo/data'",
      "sudo su -c 'touch /home/${var.adminuser}/.env'",
      "sudo su -c 'echo \"MONGO_URL=${var.mongo_url}\" >> /home/${var.adminuser}/.env '",
      "sudo su -c 'echo \"PORT=${var.port}\" >> /home/${var.adminuser}/.env '",
      "sudo su -c 'echo \"MONGO_DB=${var.mongo_db}\" >> /home/${var.adminuser}/.env '",
      "sudo su -c 'echo \"MAIL_SECRET_KEY=${var.mail_secret_key}\" >> /home/${var.adminuser}/.env '",
      "sudo su -c 'echo \"MAPBOX_ACCESS_TOKEN=${var.mapbox_access_token}\" >> /home/${var.adminuser}/.env '",
      "sudo su -c 'echo \"MAIL_SERVICE=${var.mail_service}\" >> /home/${var.adminuser}/.env '",
      "sudo su -c 'echo \"MAIL_USER=${var.mail_user}\" >> /home/${var.adminuser}/.env '",
      "sudo su -c 'echo \"MONGO_INITDB_ROOT_USERNAME=${var.mongo_initdb_root_username}\" >> /home/${var.adminuser}/.env '",
      "sudo su -c 'echo \"MONGO_INITDB_ROOT_PASSWORD=${var.mongo_initdb_root_password}\" >> /home/${var.adminuser}/.env '",
      "sudo su -c 'echo \"DOMAIN=${var.domain}\" >> /home/${var.adminuser}/.env '",
    ]
    connection {
      type        = "ssh"
      user        = var.adminuser
      private_key = file(var.ssh_key_path)
      host        = self.public_ip_address
    }
  }
}

resource "time_sleep" "wait_2_minutes" {
  depends_on      = [azurerm_linux_virtual_machine.IN-VM]
  create_duration = "120s"
}   

resource "null_resource" "init_docker" {
  depends_on = [time_sleep.wait_2_minutes]
  connection {
    type        = "ssh"
    user        = var.adminuser
    private_key = file(var.ssh_key_path)
    host        = azurerm_linux_virtual_machine.IN-VM.public_ip_address
  }
  provisioner "remote-exec" {
    inline = ["sudo su -c 'docker-compose up -d'"]
  }
}