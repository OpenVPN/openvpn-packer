#!/bin/bash

# Move persistent scripts uploaded by Packer to correct places in the
# filesystem.
#
# We do not put these files can't be under $HOME, because its location depends
# on the runtime environment. For example Packer will translate it to /root.
# We also can't hardcode these to /home/ubuntu or /home/openvpnas and expect
# this to work in the general case. 
#
set -e

mv /tmp/as-svc.sh /sbin
chmod +x /sbin/as-svc.sh
chown root:root /sbin/as-svc.sh

mv /tmp/asinit.service /etc/systemd/system/
chown root:root /etc/systemd/system/asinit.service
systemctl enable asinit.service

mv /tmp/as-version /sbin
chmod +x /sbin/as-version
chown root:root /sbin/as-version

mv /tmp/iptables-cmp /sbin
chmod +x /sbin/iptables-cmp
chown root:root /sbin/iptables-cmp
#
