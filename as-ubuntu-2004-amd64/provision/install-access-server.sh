#!/bin/bash
#
# Install Access Server and its dependencies
#
set -e
export DEBIAN_FRONTEND=noninteractive

# Enable automatic updates
echo unattended-upgrades unattended-upgrades/enable_auto_updates boolean true | debconf-set-selections
dpkg-reconfigure -f noninteractive unattended-upgrades

# Install Access Server prerequisites and other tools
apt-get update
apt-get -y install ca-certificates wget net-tools bridge-utils build-essential nano tcpdump lsof dialog unattended-upgrades net-tools locales libmysqlclient-dev tzdata chrony
apt-get -y dist-upgrade

# Install Access Server
wget -qO - https://as-repository.openvpn.net/as-repo-public.gpg | apt-key add -
echo "deb http://as-repository.openvpn.net/as/debian focal main">/etc/apt/sources.list.d/openvpn-as-repo.list
apt-get -y update
apt-get -y install openvpn-as

# Disable AS service to prevent startup errors
systemctl stop openvpnas
systemctl disable openvpnas

# Do not automatically update openvpn-as package
apt-mark hold openvpn-as

# Remove the user created by Access Server installation
userdel -rf openvpn

# Remove files left over by Access Server installation
rm -f /usr/local/openvpn_as/etc/as.conf
rm -f /usr/local/openvpn_as/etc/db/*
rm -f /usr/local/openvpn_as/init.log
