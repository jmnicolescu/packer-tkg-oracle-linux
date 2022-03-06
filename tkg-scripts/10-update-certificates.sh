#!/bin/bash -eu

#--------------------------------------------------------------------------------------
# Oracle Linux R7 - Configure the system to trust thr CA certificates [ 10-update-certificates.sh ]
# juliusn - Sun Dec  5 08:48:39 EST 2021 - first version
#--------------------------------------------------------------------------------------

echo "#--------------------------------------------------------------"
echo "# Starting 10-update-certificates.sh"
echo "#--------------------------------------------------------------"

# Trust the CA certificates at OS Level - Oracle Linux
#
echo "Copying certs to /etc/pki/ca-trust/source/anchors."
mkdir -p /etc/pki/ca-trust/source/anchors
cp /root/certs/*.crt /etc/pki/ca-trust/source/anchors/

echo "Running update-ca-trust..."
update-ca-trust
update-ca-trust force-enable

# Trust the CA certificates at OS Level - Ubuntu
#
# echo "Copying certs to /usr/local/share/ca-certificates."
# mkdir -p /usr/local/share/ca-certificates
# cp /root/certs/*.crt /usr/local/share/ca-certificates/
#
# echo "Running update-ca-trust..."
# update-ca-certificates

# Trust the CA certificates at OS Level - Photon OS
#
# echo "Copying certs to /etc/ssl/certs."
# mkdir -p /etc/ssl/certs /etc/pki/tls/certs
# cp /root/certs/*.crt /etc/ssl/certs/
# cat /etc/ssl/certs/*.crt >> /etc/pki/tls/certs/ca-bundle.crt
#
# echo "Running rehash_ca_certificates.sh ..."
# /usr/bin/rehash_ca_certificates.sh

# Trust the CA certificates at Docker level
mkdir -p /etc/docker/certs.d
cp -f /root/certs/* /etc/docker/certs.d/

echo "Done 10-update-certificates.sh"
