variable "resourse_group" {
  type = string
}

variable "location" {
  type = string
}

variable "environment" {
  type = string

}

variable "vnet_name" {
  type = string
}

variable "subnet_name" {
  type = string

}

variable "security_group_name" {
  type = string
}

variable "ip_name" {
  type = string

}

variable "nic_name" {
  type = string
}

variable "server_name" {
  type = string
}

variable "ssh_key_path" {
    type = string
  
}

variable "adminuser" {
  type = string
}

variable "mongo_url" {
    type = string
}

variable "port" {
 type = string 
}

variable "mongo_db" {
  type = string
}

variable "mail_secret_key" {
  type = string
}

variable "mapbox_access_token" {
  type = string 
}

variable "mail_service" {
  type = string 
}

variable "mail_user" {
type = string
}

variable "mongo_initdb_root_username" {
  type = string
}

variable "mongo_initdb_root_password" {
   type = string
}

variable "domain" {
  type = string
}