#Provider Config

#Proxmox Server Address
variable "proxmox_host" {
  default = "xxxxx"
}

#Proxmox Server Admin Token
variable "proxmox_token" {
  default = "xxxxx"
}

#Proxmox Server Admin Token Secret
variable "proxmox_token_secret" {
  default = "xxxxx"
}

#Proxmox Server FQDN
variable "proxmox_fqdn" {
  default = "xxxxx"
}

#Node name on Proxmox Server
variable "proxmox_node" {
  default = "xxxxx"
}

#VM Template to Clone from
variable "template_name" {
  default = "xxxxx"
}

#VM name to create
variable "hostname" {
  default = "xxxxx"
}

#VM FQDN to setup
variable "fqdn" {
  default = "xxxxx"
}

#VM SSH User Key to add into trusted
variable "ssh_pubkey" {
  default = "xxxxx"
}