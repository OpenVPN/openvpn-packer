#!/bin/bash
#
# Change the default user from "ubuntu" to "openvpnas"
#
# - This is not required for Qemu builds
# - This does not work on Digital Ocean

# Prepare the home directory for "openvpnas"
rm -rf /home/openvpnas/
mkdir /home/openvpnas/
cp /root/.bashrc /root/.profile /home/openvpnas/

sed -i -E 's/([[:space:]]+)name: ubuntu/\1name: openvpnas/g' /etc/cloud/cloud.cfg
cloud-init clean
