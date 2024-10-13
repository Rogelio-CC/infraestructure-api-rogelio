
module "dev_vm" {
  source                     = "../../modules/vm"
  environment                = "dev"
  mail_secret_key            = var.MAIL_SECRET_KEY
  mail_user                  = var.MAIL_USER
  adminuser                  = "adminuser"
  domain                     = var.DOMAIN
  resourse_group             = "IN-RG-Rogelio"
  nic_name                   = "IN-NIC-Rogelio"
  mail_service               = var.MAIL_SERVICE
  security_group_name        = "IN-SG-Rogelio"
  ssh_key_path               = "./key/712incident_server"
  port                       = var.PORT
  server_name                = "IN-Server-Rogelio"
  location                   = "eastus2"
  mapbox_access_token        = var.MAPBOX_ACCESS_TOKEN
  mongo_url                  = var.MONGO_URL
  subnet_name                = "IN-SUBNET-Rogelio"
  mongo_initdb_root_username = var.MONGO_INITDB_ROOT_USERNAME
  mongo_initdb_root_password = var.MONGO_INITDB_ROOT_PASSWORD
  mongo_db                   = var.MONGO_DB
  ip_name                    = "IN-IP-Rogelio"
  vnet_name                  = "IN-VNET-Rogelio"

}

resource "azurerm_resource_group" "RG_RogelioCC" {
  name     = "rc-rogeliocc"
  location = "eastus2"
}