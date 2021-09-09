#!/bin/bash
#
# Clean up the image
#
set -e

export DEBIAN_FRONTEND=noninteractive

service rsyslog stop

rm -f /etc/apt/sources.list
rm -f /etc/legal
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

truncate /var/log/syslog --size 0
truncate /var/log/auth.log --size 0
truncate /var/log/dpkg.log --size 0

apt-get autoremove --purge -y
apt-get clean
apt-get autoclean

# Ensure that cloud-init runs all the steps on first boot. Scripts that modify
# cloud-init configuration may run this as well.
cloud-init clean
