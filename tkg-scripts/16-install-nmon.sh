#!/bin/bash -eu
 
#--------------------------------------------------------------------------------------
# Download and Install Hashicorp tools  [ 16-install-nmon.sh ]
# juliusn - Sun Dec  5 08:48:39 EST 2021 - first version
#--------------------------------------------------------------------------------------

echo "#--------------------------------------------------------------"
echo "# Starting 16-install-nmon.sh"
echo "#--------------------------------------------------------------"

wget http://sourceforge.net/projects/nmon/files/nmon16e_x86_rhel72 -O /usr/local/bin/nmon
chmod 755 /usr/local/bin/nmon

echo "Done 16-install-nmon.sh"

