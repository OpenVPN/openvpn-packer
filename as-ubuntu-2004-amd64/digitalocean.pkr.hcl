variable "digitalocean_api_token" {
  type = string
  default = "undefined"
}

source "digitalocean" "api" {
  api_token     = var.digitalocean_api_token
  image         = "ubuntu-20-04-x64"
  region        = "fra1"
  size          = "s-1vcpu-2gb"
  snapshot_name = "packer-as-{{timestamp}}"
  ssh_username  = "root"
}

build {
  name = "digitalocean"

  sources = ["source.digitalocean.api"]

  # These scripts are persistent and may run after initial provisioning
  provisioner "file" {
    sources     = [
                    "as-ubuntu-2004-amd64/provision/as-svc.sh",
                    "as-ubuntu-2004-amd64/provision/asinit.service",
                    "as-ubuntu-2004-amd64/provision/as-version",
                    "as-ubuntu-2004-amd64/provision/iptables-cmp"
                  ]
    destination = "/tmp/"
  }

  # Upload the provisioning scripts
  provisioner "file" {
    sources     = [
                    "as-ubuntu-2004-amd64/provision/move-persistent-scripts.sh",
                    "as-ubuntu-2004-amd64/provision/install-access-server.sh",
                    "as-ubuntu-2004-amd64/provision/enable-installation-wizard.sh",
                    "as-ubuntu-2004-amd64/provision/set-hostname.sh",
                    "as-ubuntu-2004-amd64/provision/preserve-hostname.sh",
                    "as-ubuntu-2004-amd64/provision/set-motd.sh",
                    "as-ubuntu-2004-amd64/provision/cleanup.sh"
                  ]
    destination = "/tmp/"
  }

  # Run the provisioning scripts
  provisioner "shell" {
    script          = "as-ubuntu-2004-amd64/provision/init-digitalocean.sh"
    execute_command = "sudo bash {{.Path}}"
  }
}
