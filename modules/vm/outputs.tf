output "IN_IP_Output" {
  value = "${var.environment}: ${azurerm_linux_virtual_machine.IN-VM.public_ip_address}"
}