#!/bin/bash
#
# Ensure that motd is reasonable
set -e

# Remove most distro-specific motd fragments
rm -f /etc/update-motd.d/10-help-text
rm -f /etc/update-motd.d/50-motd-news
rm -f /etc/update-motd.d/85-fwupd
rm -f /etc/update-motd.d/88-esm-announce
rm -f /etc/update-motd.d/91-contract-ua-esm-status
rm -f /etc/update-motd.d/91-release-upgrade
rm -f /etc/update-motd.d/95-hwe-eol

# Add the default Access Server motd
echo "OpenVPN Access Server Appliance 2.0.0 \n \l" > /etc/issue
sed -i 's/printf .*/echo "Welcome to OpenVPN Access Server Appliance 2.0.0"/' /etc/update-motd.d/00-header

# Correct the Access Server version number in motd. This script runs whenever
# Access Server is restarted as well.
as-version

# Disable dynamic motd updates
systemctl mask motd-news
