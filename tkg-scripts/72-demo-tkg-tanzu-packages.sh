#!/bin/bash -eu

#--------------------------------------------------------------------------
# Tanzu Kubernetes Grid - Install Fluent Bit using TCE Tanzu Packages. 
# juliusn - Sun Dec  5 08:48:39 EST 2021 - first version
#
# Reference:
# https://cormachogan.com/2021/10/05/getting-started-with-carvel-and-tanzu-packages-in-tce/
#--------------------------------------------------------------------------

source ${HOME}/scripts/00-tkg-build-variables.sh

if [ ! -f ${HOME}/.kube/config-${WKLD_CLUSTER_NAME} ]; then
    echo "File: ${HOME}/.kube/config-${WKLD_CLUSTER_NAME} missing ..."
    echo "Exiting ..."
    exit 1
fi

export KUBECONFIG=${HOME}/.kube/config-${WKLD_CLUSTER_NAME}

echo "Installing repository to the default namespace."
echo "Adding TKG package repository..."

echo "#--------------------------------------------------------------"
echo "TKG repository list"
echo "#--------------------------------------------------------------"
tanzu package repository list -A

echo "#--------------------------------------------------------------"
echo "TKG package repository -> Checking available package list ..."
echo "#--------------------------------------------------------------"
tanzu package available list

echo "#--------------------------------------------------------------"
echo "TKG package repository -> Checking installed package list ..."
echo "#--------------------------------------------------------------"
tanzu package installed list

#--------------------------------------------------------------------------
# Demo App: Fluent Bit
#--------------------------------------------------------------------------

DEMO_FLUENT_BIT_PACKAGE="fluent-bit.tanzu.vmware.com"

echo "Demo App: Installing fluent-bit -- Fluent Bit is a fast Log Processor and Forwarder"
tanzu package available list ${DEMO_FLUENT_BIT_PACKAGE}
fluentbit_version=$(tanzu package available list ${DEMO_FLUENT_BIT_PACKAGE} -o json | jq -r '.[0].version | select(. !=null)')
tanzu package install fluent-bit --package-name ${DEMO_FLUENT_BIT_PACKAGE} --version "${fluentbit_version}"

echo "#--------------------------------------------------------------"
echo "TKG package repository -> Checking installed package list ..."
echo "#--------------------------------------------------------------"
tanzu package installed list

