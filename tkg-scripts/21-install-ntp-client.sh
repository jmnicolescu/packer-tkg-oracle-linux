#!/bin/bash -eu

#--------------------------------------------------------------------------------------
# Oracle Linux R7 - Configure NTP client [ 21-install-ntp-client.sh ]
# juliusn - Sun Dec  5 08:48:39 EST 2021 - first version
#--------------------------------------------------------------------------------------

echo "#--------------------------------------------------------------"
echo "# Starting 21-install-ntp-client.sh" 
echo "#--------------------------------------------------------------"

systemctl stop chronyd
systemctl disable chronyd
  
yum -y install ntp

# Set timezone
timedatectl set-timezone Europe/London

#------------------------------------
# Update /etc/ntp.conf
#------------------------------------
cp /etc/ntp.conf /etc/ntp.conf.org

cat << EOF > /etc/ntp.conf
driftfile /var/lib/ntp/ntp.drift

# Permit time synchronization with our time source, but do not
# permit the source to query or modify the service on this system.
restrict default nomodify notrap nopeer noquery

# Permit all access over the loopback interface.  This could
# be tightened as well, but to do so would effect some of
# the administrative functions.
restrict 127.0.0.1 
restrict ::1

server 3.pool.ntp.org iburst
server 2.pool.ntp.org iburst
server 1.pool.ntp.org iburst
server 0.pool.ntp.org iburst
EOF

systemctl enable ntpd
systemctl start ntpd

echo "Done 21-install-ntp-client.sh"


