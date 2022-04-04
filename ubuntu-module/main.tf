#Connect and download provider from Terraform Registry
terraform {
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "2.9.6"
    }
  }
}

#Setup server credentials for provider above
provider "proxmox" {
  #in format "https://server.xyz:8006/api2/json"
  pm_api_url = var.proxmox_host
  #in format "terraformuser@pam!terraform_token"
  pm_api_token_id = var.proxmox_token
  #in format "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
  pm_api_token_secret = var.proxmox_token_secret
  #disable https cert check if using self-signed cert (default)
  pm_tls_insecure = true
}

#Replace vars in Cloud Init Template file to terraform vars (from file or env. vars)
data "template_file" "user_data" {
  template = file("${path.module}/files/cloud_init_template.cfg")
  vars = {
    hostname   = var.hostname
    fqdn       = var.fqdn
    ssh_pubkey = var.ssh_pubkey
  }
}

#Write new Cloud Init file for upload and apply
resource "local_file" "cloud_init_user_data_file" {
  content  = data.template_file.user_data.rendered
  filename = "${path.module}/files/user_${var.hostname}.cfg"
}

#Upload created above Cloud Init file to the Proxmox Server
resource "null_resource" "cloud_init_config_files" {
  count = 1
  connection {
    type  = "ssh"
    user  = "root"
    host  = var.proxmox_fqdn
    agent = true
  }

  provisioner "file" {
    source      = local_file.cloud_init_user_data_file.filename
    destination = "/mnt/pve/snippets/snippets/user_${var.hostname}.yml"
  }
}

#Create VM with specs (settings same as qm proxmox)
resource "proxmox_vm_qemu" "ubuntu_vm" {
  depends_on = [
    null_resource.cloud_init_config_files,
  ]

  name        = var.hostname
  target_node = var.proxmox_node
  clone = var.template_name

  agent   = 1
  os_type = "cloud-init"
  cores   = 4
  sockets = 1
  memory   = 4096
  scsihw   = "virtio-scsi-pci"
  bootdisk = "scsi0"

  disk {
    slot    = 0
    size    = "16G"
    type    = "scsi"
    storage = "samsung"
  }

  network {
    model  = "virtio"
    bridge = "vmbr1"
  }

  lifecycle {
    ignore_changes = [
      network,
    ]
  }
#Path on Proxmox server to snippets folder to save Cloud Init file
  cicustom = "user=snippets:snippets/user_${var.hostname}.yml"

  sshkeys = <<EOF
  ${var.ssh_pubkey}
  EOF
}