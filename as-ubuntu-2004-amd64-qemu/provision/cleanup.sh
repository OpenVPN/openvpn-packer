#!/bin/bash
export DEBIAN_FRONTEND=noninteractive

service rsyslog stop
service openvpnas stop

# disable AS service to prevent startup errors
systemctl disable openvpnas

rm -f /etc/apt/sources.list

rm /etc/update-motd.d/10-help-text
rm /etc/update-motd.d/50-motd-news
rm /etc/update-motd.d/85-fwupd
rm /etc/update-motd.d/88-esm-announce
rm /etc/update-motd.d/91-contract-ua-esm-status
rm /etc/update-motd.d/91-release-upgrade
rm /etc/update-motd.d/95-hwe-eol

# remove /etc/network/interfaces to work around cloud-init netplan renderer issue
# rm /etc/network/interfaces
#rm /etc/netplan/50-cloud-init.yaml

rm -f /etc/legal
rm -f /usr/local/openvpn_as/etc/as.conf
rm -f /usr/local/openvpn_as/etc/db/*
rm -f /usr/local/openvpn_as/init.log
rm -rf /home/openvpnas/
mkdir /home/openvpnas/
cp /root/.bashrc /root/.profile /home/openvpnas/
chown openvpnas:openvpnas /home/openvpnas/.bashrc /home/openvpnas/.profile
rm -rf /root/*
rm -rf /root/.ssh/
rm -f /etc/ssh/ssh_host_*
rm -rf /root/.python-eggs
rm -rf /var/log/*
mkdir /var/log/chrony
chown _chrony:_chrony /var/log/chrony
chmod 766 /var/log/chrony
rm -rf /tmp/*
rm -rf /var/cache/apt/*.bin /var/lib/apt/lists/*

apt-get autoremove --purge -y
apt-get clean
apt-get autoclean

cloud-init clean

# Remove the user created by Access Server installation
userdel -rf openvpn

# Disable password authentication for SSH
sed -i s/"PasswordAuthentication yes"/"PasswordAuthentication no"/g /etc/ssh/sshd_config

# Prevent logins with password
passwd --delete openvpnas
