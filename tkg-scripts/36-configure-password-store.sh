#!/bin/bash -eu
 
#--------------------------------------------------------------------------------------
# Download and Install PASS [ 36-configure-password-store.sh ]
# juliusn - Sun Dec  5 08:48:39 EST 2021 - first version
#
# PASS - password store - man page
# https://git.zx2c4.com/password-store/about/
#
# juliusn - Sun Dec  5 08:48:39 EST 2021 - first version
#--------------------------------------------------------------------------

echo "#--------------------------------------------------------------"
echo "# Starting 36-configure-password-store.sh" 
echo "#--------------------------------------------------------------"

#--------------------------------------------------------------------------------------
# Password store initialization
#--------------------------------------------------------------------------------------

# Create a new GPG key
gpg --batch --gen-key <<EOF
Key-Type: 1
Key-Length: 2048
Subkey-Type: 1
Subkey-Length: 2048
Name-Real: My Name
Name-Email: my.name@flexlab.local
Expire-Date: 0
EOF

# Initializing the Password Store
KEY=`gpg --list-keys | grep '^pub' | awk '{print $2}' | cut -d/ -f2`
/usr/local/bin/pass init ${KEY}

echo "To set your PASS environment variables, variable run: "
echo "---> pass insert provider_vcenter_hostname"
echo "---> pass insert provider_vcenter_username"
echo "---> pass insert provider_vsphere_password"

echo "Done 36-configure-password-store.sh"