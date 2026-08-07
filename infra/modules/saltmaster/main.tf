terraform {
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "~> 1.45"
    }
  }
}

variable "hcloud_ssh_key_id" {
  type = string
}

variable "hcloud_server_name" {
  type    = string
  default = "salt-master"
}

resource "hcloud_primary_ip" "main" {
  name          = "primary_ip_saltmaster"
  type          = "ipv4"
  location      = "hel1"
  assignee_type = "server"
  auto_delete   = true
}

resource "hcloud_server" "salt-master" {
  name        = var.hcloud_server_name
  image       = "ubuntu-24.04"
  location    = "hel1"
  server_type = "cx23"
  ssh_keys    = [var.hcloud_ssh_key_id]

  public_net {
    ipv4 = hcloud_primary_ip.main.id
  }

  user_data = templatefile("${path.module}/common_userdata_master.yaml", {
    hostname    = "${var.hcloud_server_name}"
    master_addr = hcloud_primary_ip.main.ip_address
  })
}

output "primary_ip_address" {
  value = hcloud_primary_ip.main.ip_address
}
