#!/bin/bash -eu

#--------------------------------------------------------------------------------------
# Oracle Linux R7 - Cleanup [ 20-oraclelinux-cleanup.sh ]
# juliusn - Sun Dec  5 08:48:39 EST 2021 - first version
#--------------------------------------------------------------------------------------

echo "#--------------------------------------------------------------"
echo "# Starting 20-oraclelinux-cleanup.sh"
echo "#--------------------------------------------------------------"

yum -y remove "libvirt-*"
yum -y remove hidd fprintd
yum -y remove kvm qemu-kvm qemu-kvm-common ppp
yum -y remove python-virtinst libvirt libvirt-python virt-manager libguestfs-tools

## echo "Reconfigure CentOS 7 firewalld ..."
## rm -rf /etc/firewalld/zones
## firewall-cmd --zone=public --permanent --add-service={http,https,dns,dhcp,nfs,mountd,rpc-bind,smtp,ntp,vnc-server}
## firewall-cmd --zone=public --permanent --add-port={53/udp,53/tcp,123/udp,123/tcp,514/udp,5900/tcp,5901/tcp,5902/tcp,6443/tcp,8080/tcp}
## firewall-cmd --zone=public --permanent --add-port={2376,2377,2379,2380,4240,5473,6443,7946,10250-10256,30000-32767}/tcp
## firewall-cmd --zone=public --permanent --add-port={4789,7946,8285,8472}/udp
## firewall-cmd --complete-reload
## firewall-cmd --list-all-zones
## systemctl start firewalld
## systemctl enable firewalld

echo "Disable Oracle Linux 7 firewalld ..."
systemctl disable firewalld

echo "Cleaning up tmp"
rm -rf /tmp/*

echo "Done 20-oraclelinux-cleanup.sh"