#!/bin/bash -eu
 
#--------------------------------------------------------------------------------------
# Download and Install Hashicorp tools  [ 15-install-govc.sh ]
# juliusn - Sun Dec  5 08:48:39 EST 2021 - first version
#
# Available from:
# https://github.com/vmware/govmomi/tree/master/govc
#--------------------------------------------------------------------------------------

echo "#--------------------------------------------------------------"
echo "# Starting 15-install-govc.sh"
echo "#--------------------------------------------------------------"


echo "Installing GOVC, a vSphere CLI built on top of govmomi"
cd ${HOME}
curl -L -o - "https://github.com/vmware/govmomi/releases/latest/download/govc_$(uname -s)_$(uname -m).tar.gz" | tar -C /usr/local/bin -xvzf - govc
chmod 755 /usr/local/bin/govc
govc version

cat << 'PROFILE' >> ${HOME}/.bash_profile
## GOVC NOTE
##
## Store vCenter secrets by using the pass insert command:
##     pass insert provider_vcenter_hostname
##     pass insert provider_vcenter_username
##     pass insert provider_vcenter_password
##
export GOVC_URL="https://$(pass provider_vcenter_hostname)"
export GOVC_USERNAME=$(pass provider_vcenter_username)
export GOVC_PASSWORD=$(pass provider_vcenter_password)
export GOVC_INSECURE=true
PROFILE

echo "Done 15-install-govc.sh"

