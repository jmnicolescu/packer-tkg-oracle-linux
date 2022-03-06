#!/bin/bash -eu
 
#--------------------------------------------------------------------------------------
# Download and Install PASS [ 17-install-password-store.sh ]
# juliusn - Sun Dec  5 08:48:39 EST 2021 - first version
#
# PASS - password store - man page
# https://git.zx2c4.com/password-store/about/
#--------------------------------------------------------------------------------------

echo "#--------------------------------------------------------------"
echo "# Starting 17-install-password-store.sh" 
echo "#--------------------------------------------------------------"

wget https://git.zx2c4.com/password-store/snapshot/password-store-master.tar.xz
xz -d ./password-store-master.tar.xz
tar -xvf ./password-store-master.tar
cd ./password-store-master/
make install PREFIX=/usr/local
rm -f ../password-store-master.tar

echo "Done 17-install-password-store.sh"