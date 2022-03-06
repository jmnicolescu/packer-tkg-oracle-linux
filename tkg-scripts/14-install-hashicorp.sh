#!/bin/bash -eu
 
#--------------------------------------------------------------------------------------
# Download and Install Hashicorp tools  [ 14-install-hashicorp.sh ]
#
# juliusn - Sun Dec  5 08:48:39 EST 2021 - first version
#--------------------------------------------------------------------------------------

echo "#--------------------------------------------------------------"
echo "# Starting 14-install-hashicorp.sh"
echo "#--------------------------------------------------------------"

TERRAFORM_VERSION="1.0.11"
VAULT_VERSION="1.9.0"
PACKER_VERSION="1.7.8"

if [[ $(uname -m) == "x86_64" ]]; then
  LINUX_ARCH="amd64"
elif [[ $(uname -m) == "aarch64" ]]; then
  LINUX_ARCH="arm64"
fi

echo "Installing Hashicorp terraform, packer and vault"
cd ${HOME}
wget -q https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_${LINUX_ARCH}.zip
unzip -o -d /usr/local/bin/ terraform_${TERRAFORM_VERSION}_linux_${LINUX_ARCH}.zip
wget -q https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_linux_${LINUX_ARCH}.zip
unzip -o -d /usr/local/bin/ packer_${PACKER_VERSION}_linux_${LINUX_ARCH}.zip
wget -q https://releases.hashicorp.com/vault/${VAULT_VERSION}/vault_${VAULT_VERSION}_linux_${LINUX_ARCH}.zip
unzip -o -d /usr/local/bin/ vault_${VAULT_VERSION}_linux_${LINUX_ARCH}.zip
rm ${HOME}/*.zip

chmod 755 /usr/local/bin/terraform /usr/local/bin/vault /usr/local/bin/packer

echo "Done 14-install-hashicorp.sh"

