#!/bin/bash
#
# Set hostname
#
set -e

echo "openvpnas2" > /etc/hostname
hostname openvpnas2
sed -i 's/127.0.0.1 localhost/127.0.0.1 localhost openvpnas2/' /etc/hosts
