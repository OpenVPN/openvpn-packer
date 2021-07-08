#!/bin/bash

# Generate new SSH keys if necessary
if [ ! -f /etc/ssh/ssh_host_rsa_key -o -f /etc/ssh/ssh_host_dsa_key ]
then
dpkg-reconfigure openssh-server
fi

as-version
