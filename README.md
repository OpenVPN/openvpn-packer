# openvpn-packer

## Introduction

This repository contains provisioning files for various OpenVPN projects and
products:

* [Packer](https://www.packer.io/) configuration files
* Provisioning scripts
* Autoinstall / user-data files (Ubuntu 20.04)

## Building Access Server Qemu images

Our Qemu images are built with Packer's [Qemu builder](https://www.packer.io/docs/builders/qemu).

It is assumed that your Linux system has libvirt, qemu and latest version of
Packer installed and working. The user you run packer as must belong to the
"libvirt" system group as well. You should have at least 10GB of free disk space
when you build any Qemu images.

[OpenVPN Access Server](https://openvpn.net/access-server/) BYOL ("By your own
license") Qemu images are built using two-stage process. The first stage
installs the base operating system but does not provision Access Server:

    packer build -force -only=iso.* as-ubuntu-2004-amd64

The second stage runs the provisioning scripts, taking the output from the first
step as its source:

    packer build -force -only=img.* as-ubuntu-2004-amd64

This way you do not need to reinstall the operating system when fixing
provisioning problems.

The credentials used during provisioning are "openvpnas:ubuntu". This is purely
to make debugging easier, as you can then create a new VM with virsh or
virt-manager and login to it from the Spice console. Never ever let the
password remain on a published system as it is a huge, gaping security hole. 

In fact, the password for "openvpnas" user is removed at the end of the
provisioning for this reason. For the same reason password authentication via
SSH is also disabled at the end of provisioning. This means you cannot login to
the system unless you add an authorized key for "openvpnas". This can be done
in two ways:

* [Mounting the disk image with guestmount](https://www.xmodulo.com/mount-qcow2-disk-image-linux.html) and adding an SSH public key to /home/openvpnas/.ssh/authorized_keys
* Modifying [user-data](as-ubuntu-2004-amd64-qemu/http/as-ubuntu-2004-amd64-qemu/user-data) to include authorized_keys in the SSH section (see [Autoinstall reference](https://ubuntu.com/server/docs/install/autoinstall-reference)).

## Building Access Server Digital Ocean images

First create a Digital Ocean API token. Then run the build: 

    packer build -var digitalocean_api_token=<mytoken> -force -only=digitalocean.* as-ubuntu-2004-amd64

## Notes on autoinstall and Ubuntu 20.04

This section is only relevant for building Qemu images: other builders just
take pre-built Cloud images and run provisioning scripts on top.

Ubuntu 20.04 server no longer supports preseeding, the traditional Debian way
of automating operating system installations. Instead, you need to use Autoinstall:

* https://ubuntu.com/server/docs/install/autoinstall
* https://ubuntu.com/server/docs/install/autoinstall-reference

Autoinstall can leverage cloud-init to make further changes on the first boot
of the newly created operating system instance:

* https://cloudinit.readthedocs.io/en/latest/

Our ISO-based installation approach allows, among other things, modifying the
partition layout and default system user easily.
