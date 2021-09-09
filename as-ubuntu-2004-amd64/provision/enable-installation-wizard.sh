#!/bin/bash
#
# Ensure that Access Server setup wizard launches on first login
#
set -e

echo '''# Start OpenVPN Access Server Setup Wizard on startup if it has not already been run.
if [ ! -f /usr/local/openvpn_as/etc/as.conf ]
then
sudo ovpn-init
fi''' >> /root/.bashrc

cp /root/.bashrc /etc/skel
