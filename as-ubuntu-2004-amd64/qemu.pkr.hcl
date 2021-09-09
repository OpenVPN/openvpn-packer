# Install the operating system but do not run any provisioning scripts
source "qemu" "iso" {
  vm_name              = "as-ubuntu-2004-amd64-qemu-iso-build"
  iso_url              = "http://www.releases.ubuntu.com/20.04/ubuntu-20.04.2-live-server-amd64.iso"
  iso_checksum         = "sha256:d1f2bf834bbe9bb43faf16f9be992a6f3935e65be0edece1dee2aa6eb1767423"
  memory               = 1280
  disk_image           = false
  output_directory     = "as-ubuntu-2004-amd64-qemu-iso-output"
  accelerator          = "kvm"
  disk_size            = "5000M"
  disk_interface       = "virtio"
  format               = "qcow2"
  net_device           = "virtio-net"
  boot_wait            = "3s"
  # Inspired by https://nickhowell.uk/2020/05/01/Automating-Ubuntu2004-Images/
  boot_command         = [
    # Make the language selector appear...
    " <up><wait>",
    # ...then get rid of it
    " <up><wait><esc><wait>",

    # Go to the other installation options menu and leave it
    "<f6><wait><esc><wait>",

    # Remove the kernel command-line that already exists
    "<bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs>",
    "<bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs>",
    "<bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs>",

    # Add kernel command-line and start install
    "/casper/vmlinuz ",
    "initrd=/casper/initrd ",
    "autoinstall ",
    "ds=nocloud-net;s=http://{{.HTTPIP}}:{{.HTTPPort}}/ ",
    "<enter>"
    ]
  http_directory       = "as-ubuntu-2004-amd64/http"
  shutdown_command     = "echo 'packer' | sudo -S shutdown -P now"
  # These are required or Packer will panic, even if no provisioners are not
  # configured
  ssh_username         = "openvpnas"
  ssh_password         = "ubuntu"
  ssh_timeout          = "60m"
}

# Run provisioning scripts on top of the image created above
source "qemu" "img" {
  vm_name           = "as-ubuntu-2004-amd64-qemu-img-build"
  iso_url           = "as-ubuntu-2004-amd64-qemu-iso-output/as-ubuntu-2004-amd64-qemu-iso-build"
  iso_checksum      = "none"
  disk_image        = true
  memory            = 1280
  output_directory  = "as-ubuntu-2004-amd64-qemu-img-output"
  accelerator       = "kvm"
  disk_size         = "5000M"
  disk_interface    = "virtio"
  format            = "qcow2"
  net_device        = "virtio-net"
  boot_wait         = "3s"
  shutdown_command  = "echo 'packer' | sudo -S shutdown -P now"
  ssh_username      = "openvpnas"
  ssh_password      = "ubuntu"
  ssh_timeout       = "60m"
}

build {
  name = "iso"

  sources = ["source.qemu.iso"]
}

build {
  name = "img"

  sources = ["source.qemu.img"]


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
                    "as-ubuntu-2004-amd64/provision/cleanup.sh",
                    "as-ubuntu-2004-amd64/provision/disable-ssh-password-auth.sh"
                  ]
    destination = "/tmp/"
  }

  # Run the provisioning scripts
  provisioner "shell" {
    script          = "as-ubuntu-2004-amd64/provision/init-qemu.sh"
    execute_command = "sudo bash {{.Path}}"
  }
}
