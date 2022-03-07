
### Tanzu Kubernetes Grid - An automated deployment to VMware vSphere

### Build Platform - Oracle Linux R7

#### Summary

Create a custom environment that pre-bundles all required dependencies to automate the deployment of Tanzu Kubernetes Grid clusters running on either VMware vSphere.

There two steps involved in deploying Tanzu Kubernetes Grid

- Step 1. Deploy a custom Oracle Linux VM using Packer to a target environment of choice. 
          Choices include Vmware Fusion, Oracle VirtualBox, VMware ESXi or VMware vCenter.

- Step 2. Login to the custom Linux VM and deploy Tanzu Kubernetes Grid clusters.


#### Features:

Tanzu Kubernetes Grid deployment options:

- Deployment #1 - Tanzu Kubernetes Grid Deployment to vSphere 
    - Deploy TKG Management Cluster to vSphere as the target infrastructure provider 
    - Deploy TKG Workload Cluster

- Deployment #2 - Tanzu Kubernetes Grid Deployment to vSphere while using NSX Advanced Load Balancer (NSX ALB)
    - Deploy TKG Management Cluster to vSphere as the target infrastructure provider
    - Deploy TKG Workload Cluster

- Deploy sample demo applications including Metallb Load Balancer, Fluent Bit and Kubernetes Dashboard.
- Easily access and debug TKG Clusters using Octant


#### References:

- TKG documentation
    https://docs.vmware.com/en/VMware-Tanzu-Kubernetes-Grid/index.html
    
- TKG troubleshooting pages:
    https://docs.vmware.com/en/VMware-Tanzu-Kubernetes-Grid/1.4/vmware-tanzu-kubernetes-grid-14/GUID-troubleshooting-tkg-tips.html


#### Tanzu Kubernetes Grid component versions:


1. Tanzu Kubernetes Grid      v1.4.2
2. kubectl                    v1.21.8
3. Kubernetes Node OS OVA     photon-3-kube-v1.21.8+vmware.1-tkg.2-49e70fcb8bdd006b8a1cf7823484f98f.ova


#### Directory structure:

```
[packer-tkg-oracle-linux]
  │ 
  ├── http_directory                                        <-- kickstart file location
  │   └── oracle-linux
  │       └── ol7-kickstart.cfg
  ├── iso                                                   
  │   └── OracleLinux-R7-U9-Server-x86_64-dvd.iso           <-- Oracle Linux ISO file
  ├── ova                                                   <-- OVA directory
  │   ├── controller-21.1.2-9124.ova
  │   └── photon-3-kube-v1.21.8+vmware.1-tkg.2-49e70fcb8bdd006b8a1cf7823484f98f.ova
  ├── tkg
  │   ├── kubectl-linux-v1.21.8+vmware.1-142.gz             <-- Compatible kubectl
  │   └── tanzu-cli-bundle-linux-amd64.tar                  <-- Tanzu Kubernetes Grid CLI
  └── tkg-scripts                                           <-- Configuration scripts

```

#### Software Requirements:

1. Oracle Linux R7 ISO: OracleLinux-R7-U9-Server-x86_64-dvd.iso
    - [Download Oracle Linux R7 Installation Media](https://yum.oracle.com/ISOS/OracleLinux/OL7/u9/x86_64/OracleLinux-R7-U9-Server-x86_64-dvd.iso)
    - copy OracleLinux-R7-U9-Server-x86_64-dvd.iso to the iso directory.

2. Photon v3 Kubernetes v1.21.8 OVA: photon-3-kube-v1.21.8+vmware.1-tkg.2-49e70fcb8bdd006b8a1cf7823484f98f.ova
    - [Download Kubernetes node OS OVA](https://customerconnect.vmware.com/downloads/details?downloadGroup=TKG-151&productId=988)
    - copy photon-3-kube-v1.21.8+vmware.1-tkg.2-49e70fcb8bdd006b8a1cf7823484f98f.ova to the ova directory

3. Tanzu Kubernetes Grid, Tanzu CLI bundle v1.4.2: tanzu-cli-bundle-linux-amd64.tar
    - [Download Tanzu CLI bundle](https://customerconnect.vmware.com/downloads/details?downloadGroup=TKG-142&productId=988)
    - copy tanzu-cli-bundle-linux-amd64.tar to tkg directory

4. Kubectl, kubectl cluster cli v1.21.8 for Linux: kubectl-linux-v1.21.8+vmware.1-142.gz      
    - [Download kubectl](https://customerconnect.vmware.com/downloads/details?downloadGroup=TKG-142&productId=988)
    - copy kubectl-linux-v1.21.8+vmware.1-142.gz to tkg directory


Note: Tanzu Kubernetes Grid, kubectl version and the matching Photon v3 Kubernetes OVA version:

1. Version: tkg v1.4.2  -->>  kubectl v1.21.8  -->> photon-3-kube-v1.21.8+vmware.1-tkg.2-49e70fcb8bdd006b8a1cf7823484f98f.ova
[Download tkg v1.4.0](https://customerconnect.vmware.com/downloads/details?downloadGroup=TKG-142&productId=988)

2. Version: tkg v1.4.0  -->>  kubectl v1.21.2  -->> photon-3-kube-v1.21.2+vmware.1-tkg.2-12816990095845873721.ova
[Download tkg v1.4.0](https://customerconnect.vmware.com/downloads/details?downloadGroup=TKG-140&productId=988)


## 1. Building the custom Linux VM 

Configuration file used for building the custom Linux VM: `ol7.pkrvars.hcl`

Before initiating the build you'll need to set Packer build environment:

The following environment variables are required by the Packer build script:

  1. PKR_VAR_vcenter_hostname       <-- vCenter host name
  2. PKR_VAR_vcenter_username       <-- vCenter user
  3. PKR_VAR_vcenter_password       <-- vCenter password
  4. PKR_VAR_vm_access_username     <-- user to SSH to the custom VM
  5. PKR_VAR_vm_access_password     <-- password for the SSH user


We'll manage all the above environment variables with GPG and PASS.
PASS is the standard unix password manager. Please refer to [Manage Passwords With GPG and PASS](README-PASS.md) for addition info about setting up PASS.

1. Insert the variables in the password store

  - pass insert provider_vcenter_hostname
  - pass insert provider_vsphere_user
  - pass insert provider_vsphere_password
  - pass insert vm_access_username
  - pass insert vm_access_password

2. Read the secrets from pass and set them as environment variables

  - export PKR_VAR_vcenter_hostname=$(pass provider_vcenter_hostname)
  - export PKR_VAR_vcenter_username=$(pass provider_vcenter_username)
  - export PKR_VAR_vcenter_password=$(pass provider_vcenter_password)
  - export PKR_VAR_vm_access_username=$(pass vm_access_username)
  - export PKR_VAR_vm_access_password=$(pass vm_access_password)

In addition, we'll need to edit Packer Variable definition file [ol7.pkrvars.hcl](ol7.pkrvars.hcl)  to set the rest of vCenter variables required for the build.


#### VM Deployment Option #1 - Deployment to VMware Fusion

To deploy the custom Oracle Linux R7 VM to VMware Fusion run the following command:

```bash
packer build -var-file=ol7.pkrvars.hcl ol7-fusion.pkr.hcl
```

#### VM Deployment Option #2 - Deployment to an ESXi host

To allow packer to work with the ESXi host - enable “Guest IP Hack”

```bash
  esxcli system settings advanced set -o /Net/GuestIPHack -i 1
```

To deploy the custom Oracle Linux R7 VM to an ESXi host run the following command:

```bash
  packer build -var-file=ol7.pkrvars.hcl ol7-esxi.pkr.hcl
```

#### VM Deployment Option #3 - Deployment to VMware vSphere

To deploy the custom Oracle Linux R7 VM to VMware vSphere run the following command:

```bash
packer build -var-file=ol7.pkrvars.hcl ol7-vcenter.pkr.hcl
```

#### VM Deployment Option #4 - Deployment to Oracle VirtualBox

To deploy the custom Oracle Linux R7 VirtualBox VM in the OVF format run the following command:

```bash
packer build -var-file=ol7.pkrvars.hcl ol7-virtualbox.pkr.hcl
```

## 2. TKG installation and cluster configuration

Configuration file used for TKG deployment: `scripts/00-TKG-build-variables.sh`

Optional: For the custom Linux VM, update /etc/hosts file with the IP address obtained from DHCP server OR set a static IP.

```bash
# Update host entry in the /etc/hosts file using the current DHCP assigned IP
 sudo ./30-update-etc-hosts.sh

 OR

 # Set a static IP for the custom Linux VM
 sudo ./30-configure-with-static-ip.sh
```

Setting the TKG build environment:

With the exception of vCenter credentials, all TKG Build Variable are set in 00-TKG-build-variables.sh
Please review and update [Tanzu Kubernetes Grid - Build Variable Definition](scripts/00-TKG-build-variables.sh) file.


#### Network Considerations

Kube-Vip is used solely by the cluster’s API server.

To load-balance workloads on vSphere, there are two deployment options available:
1. TKG deployment using Metallb Load Balancer
2. TKG deployment using NSX Advanced Load Balancer


#### TKG Deployment option #1 - TKG deployment to VMware vSphere using Metallb to load-balance workloads.

Login to the Linux VM as user TKG, chnage directory to scripts and run the following scripts:

```bash  
cd scripts

# Insert the vCenter host name and user credentials into the password store
pass insert provider_vcenter_hostname
pass insert provider_vcenter_username
pass insert provider_vcenter_password

# Update host entry in the /etc/hosts file using the current DHCP assigned IP
sudo ./30-update-etc-hosts.sh

# Reset Environment and Install Tanzu Kubernetes Grid
./33-tkg-install.sh

# vSphere Requirerments, Deploy Kubernetes node OS VM 
./50-vsphere-deploy-k8s-ova

# Deploy a Management Cluster to vSphere 
./52-vsphere-deploy-management.sh

# Deploy a Workload Cluster to vSphere
./53-vsphere-deploy-workload.sh

# Deploy Metallb Load Balancer
./70-demo-deploy-metallb.sh

# Deploy demo application: assembly-webapp
./71-demo-deploy-assembly-webapp.sh

# Install Fluent Bit using TKG Tanzu Packages
./72-demo-tkg-tanzu-packages.sh

# Deploy Kubernetes Dashboard
./73-demo-deploy-k8s-dashboard.sh

```

#### TKG Depolyment option #2 - TKG deployment to VMware vSphere using NSX Advanced Load Balancer to load-balance workloads.

Login to the Linux VM as user TKG, chnage directory to scripts and run the following scripts:
  
```bash  
cd scripts

# Insert the vCenter host name and user credentials into the password store
pass insert provider_vcenter_hostname
pass insert provider_vcenter_username
pass insert provider_vcenter_password

# Update host entry in the /etc/hosts file using the current DHCP assigned IP
sudo ./30-update-etc-hosts.sh

# Reset Environment and Install Tanzu Kubernetes Grid
./33-tkg-install.sh

# vSphere Requirerments, Deploy Kubernetes node OS VM 
./50-vsphere-deploy-k8s-ova

# Deploy NSX Advanced Load Balancer OVA
./60-nsx-alb-deploy-avi-ova.sh

# Configure NSX Advanced Load Balancer 
# Follow [README-NSX-ALB.md guide](README-NSX-ALB.md) to configure NSX ALB

# Deploy a Management Cluster to vSphere using NSX ALB
./62-nsx-alb-deploy-management.sh

# Deploy a Workload Cluster to vSphere using NSX ALB
./63-nsx-alb-deploy-workload.sh

# Deploy demo application: assembly-webapp
./71-demo-deploy-assembly-webapp.sh

# Install Fluent Bit using TKG Tanzu Packages
./72-demo-tkg-tanzu-packages.sh

# Deploy Kubernetes Dashboard
./73-demo-deploy-k8s-dashboard.sh

```

## 3. Accessing Tanzu Kubernetes Grid clusters from the custom Linux VM

#### To access TKG management cluster, login as TKG user and run:

```bash
export MGMT_CLUSTER_NAME="tkg-management"
export KUBECONFIG=${HOME}/.kube/config-${MGMT_CLUSTER_NAME}
kubectl get nodes -A
```
The management cluster kubeconfig file `${HOME}/.kube/config-${MGMT_CLUSTER_NAME}` is created during the install.

If you need to recapture the management cluster’s kubeconfig, execute the following commands:

```bash
export MGMT_CLUSTER_NAME="tkg-management"
export KUBECONFIG=${HOME}/.kube/config-${MGMT_CLUSTER_NAME}
tanzu management-cluster kubeconfig get --admin
kubectl config use-context ${MGMT_CLUSTER_NAME}-admin@${MGMT_CLUSTER_NAME}
kubectl get nodes -A
```

#### To access TKG workload cluster, login as TKG user and run:

```bash 
  export WKLD_CLUSTER_NAME="tkg-workload"
  export KUBECONFIG=${HOME}/.kube/config-${WKLD_CLUSTER_NAME}
  tanzu cluster kubeconfig get ${WKLD_CLUSTER_NAME} --admin
  kubectl config use-context ${WKLD_CLUSTER_NAME}-admin@${WKLD_CLUSTER_NAME}
  kubectl get nodes -A
```
The workload cluster kubeconfig file `${HOME}/.kube/config-${WKLD_CLUSTER_NAME}` is created during the install.

If you need to recapture the workload cluster’s kubeconfig, execute the following commands:

```bash 
  export WKLD_CLUSTER_NAME="tkg-workload"
  tanzu cluster kubeconfig get ${WKLD_CLUSTER_NAME} --admin
  kubectl config use-context ${WKLD_CLUSTER_NAME}-admin@${WKLD_CLUSTER_NAME}
  kubectl get nodes -A
  
  or just:
  export KUBECONFIG=${HOME}/.kube/config-${WKLD_CLUSTER_NAME}
  kubectl get nodes -A
```

## 4. Troubleshooting tips:

The bootstrap cluster kubeconfig is located in `${HOME}/.kube-tkg/tmp` directory.
To check the progress of the install run:

```bash 
export KUBECONFIG=`ls ${HOME}/.kube-tkg/tmp/config_*`
kubectl get pods,deployments -A
kubectl get kubeadmcontrolplane,machine,machinedeployment -A
kubectl get events -A
```

To recover from a failed deployment, wipe all previous TKG configurations and reset the environment execute the following commands:

```bash
# Docker Cleanup - Stop all existing containers, remove containers, prune all existing volumes
./34-docker-cleanup.sh

# Wipe all previous TKG configurations, Reset Environment and Install Tanzu Kubernetes Grid
./33-tkg-install.sh
```