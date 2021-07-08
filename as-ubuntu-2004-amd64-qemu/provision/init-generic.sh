#!/bin/bash
export DEBIAN_FRONTEND=noninteractive

echo unattended-upgrades unattended-upgrades/enable_auto_updates boolean true | debconf-set-selections
dpkg-reconfigure -f noninteractive unattended-upgrades

apt update && apt -y install ca-certificates wget net-tools bridge-utils build-essential nano tcpdump lsof dialog unattended-upgrades net-tools locales libmysqlclient-dev tzdata chrony && apt -y dist-upgrade

wget -qO - https://as-repository.openvpn.net/as-repo-public.gpg | apt-key add -
echo "deb http://as-repository.openvpn.net/as/debian focal main">/etc/apt/sources.list.d/openvpn-as-repo.list
apt update && apt -y install openvpn-as
apt-mark hold openvpn-as

sed -i 's/preserve_hostname: false/preserve_hostname: true/' /etc/cloud/cloud.cfg

# We do not put these files can't be under $HOME, because its location depends
# on the runtime environment. For example Packer will translate it to /root.
# We also can't hardcode these to /home/ubuntu or /home/openvpnas and expect
# this to work in the general case. 
#
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

# Ensure motd is reasonable
echo "OpenVPN Access Server Appliance 2.0.0 \n \l" > /etc/issue
sed -i 's/printf .*/echo "Welcome to OpenVPN Access Server Appliance 2.0.0"/' /etc/update-motd.d/00-header

systemctl mask motd-news


as-version

echo '''# Start OpenVPN Access Server Setup Wizard on startup if it has not already been run.
if [ ! -f /usr/local/openvpn_as/etc/as.conf ]
then
sudo ovpn-init
fi''' >> /root/.bashrc

cp /root/.bashrc /etc/skel

echo "openvpnas2" > /etc/hostname
hostname openvpnas2
sed -i 's/127.0.0.1 localhost/127.0.0.1 localhost openvpnas2/' /etc/hosts
