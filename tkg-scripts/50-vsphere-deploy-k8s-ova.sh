#!/bin/bash -eu

#--------------------------------------------------------------------------
# Tanzu Community Edition / Tanzu Kubernetes Grid
# Deploy Kubernetes node OS VM
#
# Download the OVA that matches the Kubernetes node OS from VMware Customer Connect
# https://customerconnect.vmware.com/downloads/get-download?downloadGroup=TCE-090
#
# photon-3-kube-v1.21.2+vmware.1-tkg.2-12816990095845873721.ova
# SHA256SUM: 863eed478fd6a21232cb49b70cda1c1c6788b454c7b5305acf3059570f5eb6b1
#
# ubuntu-2004-kube-v1.21.2+vmware.1-tkg.1-7832907791984498322.ova
# SHA256SUM: 0965e49810b57ded9f1d28382da967997e58004ffab729a59a7c65fe645f03f0
#
# juliusn - Sun Dec  5 08:48:39 EST 2021 - first version
#--------------------------------------------------------------------------

############################################################################
##
## Store vCenter secrets by using the pass insert command:
##
##     pass insert provider_vcenter_hostname
##     pass insert provider_vcenter_username
##     pass insert provider_vcenter_password
##
#############################################################################

echo "#--------------------------------------------------------------"
echo "# Starting 50-vsphere-deploy-k8s-ova.sh" 
echo "#--------------------------------------------------------------"

echo $$ > ${HOME}/scripts/.index
unset VSPHERE_FOLDER
unset VSPHERE_RESOURCE_POOL
source ${HOME}/scripts/00-tkg-build-variables.sh

export GOVC_URL="https://$(pass provider_vcenter_hostname)"
export GOVC_USERNAME=$(pass provider_vcenter_username)
export GOVC_PASSWORD=$(pass provider_vcenter_password)
export GOVC_INSECURE=true

echo "  "
echo "Creating Resource Pool to deploy the Tanzu Community Edition Instance"
govc pool.create "/${VSPHERE_DATACENTER}/host/${VSPHERE_CLUSTER}/Resources/${VSPHERE_RESOURCE_POOL}"
govc pool.info   "/${VSPHERE_DATACENTER}/host/${VSPHERE_CLUSTER}/Resources/${VSPHERE_RESOURCE_POOL}"

echo "  "
echo "Creating VM folder in which to collect the Tanzu Community Edition VMs"
govc folder.create "/${VSPHERE_DATACENTER}/vm/${VSPHERE_FOLDER}"
govc folder.info   "/${VSPHERE_DATACENTER}/vm/${VSPHERE_FOLDER}"

## govc tags.category.create -t ClusterComputeResource k8s
## govc tags.create -c k8s ${VSPHERE_RESOURCE_POOL}
## govc tags.attach ${VSPHERE_RESOURCE_POOL} /${VSPHERE_DATACENTER}/host/${VSPHERE_CLUSTER}

echo "Sleeping 10 seconds ... wait for resource pool to be available"
sleep 10

# Extract the ova-specs from the ova image
# govc import.spec ${OVA_FILE} | jq . > ${OVA_JSON_FILE}
rm -f ${OVA_JSON_FILE}

echo "Updating ova-specs file with the Network info [ ${NETWORK_TANZU_MANAGEMENT} ]"
cat > ${OVA_JSON_FILE} << EOF
{
  "DiskProvisioning": "flat",
  "IPAllocationPolicy": "dhcpPolicy",
  "IPProtocol": "IPv4",
  "NetworkMapping": [
    {
      "Name": "nic0",
      "Network": "${NETWORK_TANZU_MANAGEMENT}"
    }
  ],
  "Annotation": "Cluster API vSphere image - VMware Photon OS 64-bit and Kubernetes v1.21.2+vmware.1",
  "MarkAsTemplate": true,
  "PowerOn": false,
  "InjectOvfEnv": false,
  "WaitForIP": false,
  "Name": null
}
EOF

echo "-----------------------------------------------------------------------------------------"
echo "Deploying Kubernetes node OS VM and converting the VM to Template."
echo "OVA file:          ${OVA_FILE}"
echo "OVA specs file:    ${OVA_JSON_FILE}"
echo "VM name:           ${OVA_VM_NAME}"
echo "VM folder:         ${VSPHERE_FOLDER}"
echo "-----------------------------------------------------------------------------------------"

govc import.ova -ds=${VSPHERE_DATASTORE} -folder=${VSPHERE_FOLDER} -pool=${VSPHERE_RESOURCE_POOL} -name=${OVA_VM_NAME} \
   -options="${OVA_JSON_FILE}" ${OVA_FILE}

echo "-----------------------------------------------------------------------------------------"
echo "Creating a new SSH Key Pair. "
echo "-> To SSH into TCE/TKG nodes [ use capv user and the private SSH key ]"
echo "-> Example: ssh -i ~/.ssh/id_rsa capv@NODE_IP"
echo "-----------------------------------------------------------------------------------------"
ssh-keygen -q -b 4096 -t rsa -N '' -f ~/.ssh/id_rsa 2>/dev/null <<< y >/dev/null

echo "Here is your SSH publick key:"
echo "-----------------------------------------------------------------------------------------"
cat ${HOME}/.ssh/id_rsa.pub 
echo "-----------------------------------------------------------------------------------------"

echo "Done 50-vsphere-deploy-k8s-ova.sh"