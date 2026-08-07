terraform {
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "~> 1.45"
    }
  }
}

provider "hcloud" {
  token = var.hcloud_token
}

variable "hcloud_token" {
  description = "Hetzner Cloud API Token"
  type        = string
  sensitive   = true
}

resource "hcloud_ssh_key" "main" {
  name       = "auto_ssh"
  public_key = file("../id_ed25519.pub")
}

module "salt-master" {
  source = "./modules/saltmaster"

  hcloud_server_name = "server"
  hcloud_ssh_key_id  = hcloud_ssh_key.main.id
}

module "salt-minion" {
  source = "./modules/saltminion"

  hcloud_server_name = "node-0"
  hcloud_ssh_key_id  = hcloud_ssh_key.main.id
  saltmaster_ip      = module.salt-master.primary_ip_address
}

module "salt-minion" {
  source = "./modules/saltminion"

  hcloud_server_name = "node-1"
  hcloud_ssh_key_id  = hcloud_ssh_key.main.id
  saltmaster_ip      = module.salt-master.primary_ip_address
}

output "salt_master_ip" {
  value = module.salt-master.primary_ip_address
}

