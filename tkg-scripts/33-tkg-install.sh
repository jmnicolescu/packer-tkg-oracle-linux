#!/bin/bash -eu

#--------------------------------------------------------------------------
# Tanzu Kubernetes Grid - Install / ReInstall [ 33-tkg-install.sh ]
#
# Install TKG 1.4 tanzu CLI binary and the Carvel Tools
# juliusn - Wed Dec 22 05:00:37 EST 2021 - first version
#
# Tanzu Kubernetes Grid 1.4 - Install the Tanzu CLI and Other Tools
# https://docs.vmware.com/en/VMware-Tanzu-Kubernetes-Grid/1.4/vmware-tanzu-kubernetes-grid-14/GUID-install-cli.html#install-carvel
#--------------------------------------------------------------------------

echo "#--------------------------------------------------------------"
echo "# Starting 33-tkg-install.sh"
echo "#--------------------------------------------------------------"

source ${HOME}/scripts/00-tkg-build-variables.sh

if [[ "$EUID" -eq 0 ]]; then
  echo "Do not run $0 script as root"
  echo "Exiting script 33-tkg-install.sh"
  exit 1
fi

rm -rf ${HOME}/.kube-tkg ${HOME}/.kube
rm -rf ${HOME}/.tanzu ${HOME}/.config/tanzu  ${HOME}.cache/tanzu ${HOME}/.local/share/tanzu-cli ${HOME}/.local/share/tkg

#--------------------------------------------------------------------------------------
# Install Tanzu Kubernetes Grid
#--------------------------------------------------------------------------------------

echo "Installing Tanzu Kubernetes Grid from ${HOME}/tkg"
cd ${HOME}/tkg
tar xzvf tanzu-cli-bundle-linux-amd64.tar.gz

cd cli
sudo rm -f /usr/local/bin/tanzu
sudo install -o root -g root -m 0755 core/v0.11.1/tanzu-core-linux_amd64 /usr/local/bin/tanzu

#--------------------------------------------------------------------------------------
# Install the Carvel Tools - ytt, kapp, kbld, imgpkg.
#--------------------------------------------------------------------------------------

# - We are installing the latest Carvel tools in 31-tkg-download-tanzu.sh
# 
# echo "Installing the Carvel Tools - ytt, kapp, kbld, imgpkg."
# for file in $(ls *.gz)
# do
#   gunzip -f $file
#   echo "Installing /usr/local/bin/$(echo $file | awk -F - '{print $1}')"
#   sudo install -o root -g root -m 0755 ${file::-3} /usr/local/bin/$(echo $file | awk -F - '{print $1}')
# done

# Install the tanzu CLI plugins
tanzu plugin install --local . all
tanzu init

# Checking Tanzu version
tanzu version
tanzu plugin list

# Making sure that we are using the correct version of kubectl
sudo cp /usr/local/bin/kubectl-${K8S_VERSION} /usr/local/bin/kubectl

echo "Done33-tkg-install.sh"