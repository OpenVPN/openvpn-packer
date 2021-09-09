
#!/bin/bash
#
# Disable password authentication for SSH
#
# Used by the Qemu builder
#
set -e

sed -i s/"PasswordAuthentication yes"/"PasswordAuthentication no"/g /etc/ssh/sshd_config
