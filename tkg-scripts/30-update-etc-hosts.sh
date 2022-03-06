#!/bin/bash -eu

#--------------------------------------------------------------------------------------
# Update /etc/hosts file - [ 30-update-etc-hosts.sh ]
# juliusn - Sun Dec  5 08:48:39 EST 2021 - first version
#
# Update host entry in the /etc/hosts file using the current DHCP assigned IP
#
# More of a sample file as the interface differes from one platform to another
#--------------------------------------------------------------------------------------

source ${HOME}/scripts/00-tkg-build-variables.sh

echo "#--------------------------------------------------------------"
echo "# Starting 30-update-etc-hosts.sh"
echo "#--------------------------------------------------------------"

SHORT_HOST=`hostname`

echo "Updating /etc/hosts file."
sed -i '/'${SHORT_HOST}'/ d' /etc/hosts
echo "Adding [ ${MY_IP_ADDRESS} ${SHORT_HOST}.${MY_DOMAIN_NAME} ${SHORT_HOST} ] to /etc/hosts file."
echo "${MY_IP_ADDRESS} ${SHORT_HOST}.${MY_DOMAIN_NAME} ${SHORT_HOST}" >> /etc/hosts

echo "Done 30-update-etc-hosts.sh"