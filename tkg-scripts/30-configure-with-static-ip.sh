#!/bin/bash -eu

#--------------------------------------------------------------------------------------
# Oracle Linux R7 - Add static IP [ 30-configure-with-static-ip.sh ]
# juliusn - Sun Dec  5 08:48:39 EST 2021 - first version
#
# Here is a sample configuration file to set a staic IP for Oracle Linux R7
#--------------------------------------------------------------------------------------

source ${HOME}/scripts/00-tkg-build-variables.sh

echo "#--------------------------------------------------------------"
echo "# Starting 30-configure-with-static-ip.sh"
echo "#--------------------------------------------------------------"

SHORT_HOST=`hostname`

cat > /etc/sysconfig/network-scripts/ifcfg-ens192 << "EOF"
NAME="ens192"
DEVICE=ens192
ONBOOT=yes
IPADDR=192.168.120.129
GATEWAY=192.168.120.1
NETMASK=255.255.255.0
DNS1=192.168.120.1
DOMAIN=flexlab.local
BOOTPROTO="static"
PREFIX=24
DEFROUTE=yes
TYPE=Ethernet
PROXY_METHOD=none
BROWSER_ONLY=no
EOF

echo "Updating /etc/hosts file."
sed -i '/'${SHORT_HOST}'/ d' /etc/hosts
echo "Adding [ ${MY_STATIC_IP} ${SHORT_HOST}.${MY_DOMAIN_NAME} ${SHORT_HOST} ] to /etc/hosts file."
echo "${MY_STATIC_IP} ${SHORT_HOST}.${MY_DOMAIN_NAME} ${SHORT_HOST}" >> /etc/hosts

systemctl restart network

echo "Done 30-configure-with-static-ip"