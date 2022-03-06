#!/bin/sh

#--------------------------------------------------------------------------------------
# Oracle Linux R7 - Install & configure postfix [ 22-install-postfix.sh ]
# juliusn - Sun Dec  5 08:48:39 EST 2021 - first version
#--------------------------------------------------------------------------------------

HOSTNAME=`hostname`

echo "#--------------------------------------------------------------"
echo "# Starting 22-install-postfix.sh" 
echo "#--------------------------------------------------------------"

yum -y install postfix mailx

## firewall-cmd --permanent --zone=public --add-service=smtp
## firewall-cmd --permanent --zone=public --add-port=25/tcp
## firewall-cmd --reload

systemctl enable postfix
systemctl start postfix

#--------------------------------------------------------------------------------------
# Postfix main configuration file ---> /etc/postfix/main.cf
#--------------------------------------------------------------------------------------

# check Postfix version 
postconf mail_version

# The netstat utility tells us that the Postfix master process is listening on TCP port 25 
netstat -lnpt | grep master
postconf -e "inet_interfaces = all"
postconf inet_interfaces
postconf -e "inet_protocols = all"
postconf inet_protocols
postconf -e "myhostname = ${HOSTNAME}.${MY_DOMAIN_NAME}"
postconf myhostname
postconf -e "mydomain = ${MY_DOMAIN_NAME}"
postconf -e "myorigin = ${MY_DOMAIN_NAME}"
postconf mydomain
postconf -e "mydestination = ${MY_DOMAIN_NAME}, \$myhostname, localhost.\$mydomain, localhost"
postconf mydestination
postconf -e message_size_limit=52428800
postconf -e mailbox_size_limit=0
postconf -e "virtual_alias_maps = hash:/etc/postfix/virtual"

# - create virtual file
cat << EOF > /etc/postfix/virtual
#
# Execute the command "postmap /etc/postfix/virtual" to rebuild an 
# indexed file after changing the corresponding text file. 
#
# postmap /etc/postfix/virtual

juliusn@${MY_DOMAIN_NAME}  juliusn
root@${MY_DOMAIN_NAME}  root
EOF
postmap /etc/postfix/virtual

newaliases
systemctl restart postfix

echo "Done 22-install-postfix.sh"