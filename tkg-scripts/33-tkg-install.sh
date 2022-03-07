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

TANZU_CLI_BUNDLE="tanzu-cli-bundle-linux-amd64.tar"
COMPATIBLE_KUBECTL="kubectl-linux-v1.21.8+vmware.1-142.gz"

echo "#--------------------------------------------------------------"
echo "# Starting 33-tkg-install.sh"
echo "#--------------------------------------------------------------"

source ${HOME}/scripts/00-tkg-build-variables.sh

if [[ "$EUID" -eq 0 ]]; then
  echo "Do not run $0 script as root"
  echo "Exiting script 33-tkg-install.sh"
  exit 1
fi

if [ ! -f ${HOME}/tkg/${TANZU_CLI_BUNDLE} ]; then
    echo "Expecting Tanzu CLI bundle in ${HOME}/tkg/${TANZU_CLI_BUNDLE}"
    echo "Exiting ..."
    exit 1
fi

if [ ! -f ${HOME}/tkg/${COMPATIBLE_KUBECTL} ]; then
    echo "Expecting the compatible kubectl in ${HOME}/tkg/${COMPATIBLE_KUBECTL}"
    echo "Exiting ..."
    exit 1
fi

rm -rf ${HOME}/.kube-tkg ${HOME}/.kube
rm -rf ${HOME}/.tanzu ${HOME}/.config/tanzu  ${HOME}.cache/tanzu ${HOME}/.local/share/tanzu-cli ${HOME}/.local/share/tkg

#--------------------------------------------------------------------------------------
# Install Tanzu Kubernetes Grid cli
#--------------------------------------------------------------------------------------

echo "Installing Tanzu Kubernetes Grid from ${HOME}/tkg"
cd ${HOME}/tkg

tar xvf ${TANZU_CLI_BUNDLE}
sudo rm -f /usr/local/bin/tanzu
sudo install -o root -g root -m 0755 cli/core/v1.4.2/tanzu-core-linux_amd64 /usr/local/bin/tanzu

# tanzu cli update
tanzu update

# remove existing plugins from any previous CLI installations
tanzu plugin clean

echo "Installing all the plugins for the specific TKG release ${TKG_VERSION}"
tanzu plugin install --local cli all

echo "Checking Tanzu Kubernetes Grid version and installed plugins."
tanzu version
tanzu plugin list

#--------------------------------------------------------------------------------------
# Install the Carvel Tools - ytt, kapp, kbld, imgpkg.
#--------------------------------------------------------------------------------------

echo "Installing the Carvel Tools - ytt, kapp, kbld, imgpkg."
cd ${HOME}/tkg/cli

for file in $(ls *.gz)
do
  gunzip -f $file
  echo "Installing /usr/local/bin/$(echo $file | awk -F - '{print $1}')"
  sudo install -o root -g root -m 0755 ${file::-3} /usr/local/bin/$(echo $file | awk -F - '{print $1}')
done

#--------------------------------------------------------------------------------------
# Install kubectl - kubectl-linux-v1.21.8+vmware.1-142
#--------------------------------------------------------------------------------------

echo "Installing the compatible kubectl version from ${HOME}/tkg"
cd ${HOME}/tkg

gunzip -c ${COMPATIBLE_KUBECTL} > kubectl-vmware
sudo install -o root -g root -m 0755 kubectl-vmware /usr/local/bin/kubectl-vmware
sudo install -o root -g root -m 0755 kubectl-vmware /usr/local/bin/kubectl

# version check
kubectl version

echo "Done33-tkg-install.sh"