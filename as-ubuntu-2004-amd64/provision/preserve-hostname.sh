#!/bin/sh
#
# Ensure that hostname is preserved across reboots
#
set -e

sed -i 's/preserve_hostname: false/preserve_hostname: true/' /etc/cloud/cloud.cfg
cloud-init clean
