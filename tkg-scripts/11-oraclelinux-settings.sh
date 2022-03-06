#!/bin/bash -eu

#--------------------------------------------------------------------------------------
# Oracle Linux R7 - First set of OS customization [ 11-oraclelinux-settings.sh ]
# juliusn - Sun Dec  5 08:48:39 EST 2021 - first version
#--------------------------------------------------------------------------------------

echo "#--------------------------------------------------------------"
echo "# Starting 11-oraclelinux-settings.sh"
echo "#--------------------------------------------------------------"

yum -y install wget curl mc expect perl
yum -y install rsync findutils lsof which tree
yum -y install python python-setuptools python-pip
yum -y install zlib zlib-devel
yum -y install curl curl-devel
yum -y install libaio libaio-devel
yum -y install ncurses ncurses-libs ncueses-devel
yum -y install crypto-utils openssh-clients 
yum -y install openssl openssl-libs openssl-devel
yum -y install expat expat-devel
yum -y install nc nmap traceroute smartmontools
yum -y install python3 python3-setuptools python3-pip
yum -y install perl-Digest-SHA

yum clean all
yum -y update

## Issue #1 - Kind Known Issue - IPv6 Port Forwarding
## Docker assumes that all the IPv6 addresses should be reachable, hence doesn't implement port mapping using NAT

## Issue #2 - Pre-req check, ensure bootstrap machine has ipv4 forwarding enabled
## https://github.com/vmware-tanzu/tanzu-framework/issues/854

# Enable IP forwarding, IPV6 and increase connection tracking table size 
cat >> /etc/sysctl.conf << EOF
net.ipv4.ip_forward=1
net.ipv6.conf.all.forwarding=1
net.ipv6.conf.default.forwarding=1
net.netfilter.nf_conntrack_max=524288
EOF

# Docker/Tanzu requirement - Forward IPv4 or IPv6 source-routed packets
for SETTING in $(/sbin/sysctl -aN --pattern "net.ipv[4|6].conf.(all|default|eth.*).accept_source_route")
do 
    sed -i -e "/^${SETTING}/d" /etc/sysctl.conf
    echo "${SETTING}=1" >> /etc/sysctl.conf
done 

/usr/sbin/sysctl -p

chmod 755 /root/scripts /root/scripts/*

echo "Done 11-oraclelinux-settings.sh"
