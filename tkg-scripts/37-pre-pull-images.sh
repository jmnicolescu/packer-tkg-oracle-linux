#!/bin/bash -eu

#--------------------------------------------------------------------------
# Tanzu Community Edition / Tanzu Kubernetes Grid - Pre pull images [ 37-pre-pull-images.sh ]
#
# juliusn - Sun Dec  5 08:48:39 EST 2021 - first version
#--------------------------------------------------------------------------

echo "#--------------------------------------------------------------"
echo "# Starting 37-pre-pull-images.sh" 
echo "#--------------------------------------------------------------"

source ${HOME}/scripts/00-tkg-build-variables.sh

if [[ "$EUID" -eq 0 ]]; then
  echo "Do not run this script as root"
  exit 1
fi

# We should really not do this, but it helps. Images' version are provided in the $TCE_VERSION BOM file.
pre_pull_array=( \
      "projects.registry.vmware.com/tkg/kind/node:v1.21.8_vmware.1" \
      )

for image in ${pre_pull_array[@]}; do
  echo "#-----------------------------------------------------------------------------------"
  echo "Pre pull $image "
  docker pull $image
  echo "#-----------------------------------------------------------------------------------"
done

echo "Done 37-pre-pull-images.sh"