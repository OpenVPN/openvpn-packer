#!/bin/bash
#
# Qemu provisioning steps
#
set -e

/tmp/move-persistent-scripts.sh
/tmp/install-access-server.sh
/tmp/enable-installation-wizard.sh
/tmp/set-hostname.sh
/tmp/preserve-hostname.sh
/tmp/set-motd.sh
/tmp/disable-ssh-password-auth.sh
/tmp/cleanup.sh
