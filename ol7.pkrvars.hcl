#----------------------------------------------------------------------------------
# Variable definition file to build the Oracle Linux R7 image 
# juliusn - Sun Dec  5 08:48:39 EST 2021
# 
# Download Oracle Linux Installation Media and Checksum from:
# https://yum.oracle.com/oracle-linux-isos.html
# https://linux.oracle.com/security/gpg/checksum/OracleLinux-R7-U9-Server-x86_64.checksum
#----------------------------------------------------------------------------------

#----------------------------------------------------------------------------------
# Set your environment variables, or read the secrets from pass 
# and set them as environment variables
#
# -- environment variables used to SSH to the custom Linux VM
# export PKR_VAR_vm_access_username=$(pass vm_access_username)
# export PKR_VAR_vm_access_password=$(pass vm_access_password)
#
# -- environment variables needed if deploying to a vCenter Server --
# export PKR_VAR_vcenter_hostname=$(pass provider_vcenter_hostname)
# export PKR_VAR_vcenter_username=$(pass provider_vcenter_username)
# export PKR_VAR_vcenter_password=$(pass provider_vcenter_password)
#
# -- environment variables needed if deploying to an ESXi host --
# export PKR_VAR_esx_remote_hostname=$(pass esx_remote_hostname)
# export PKR_VAR_esx_remote_username=$(pass esx_remote_username)
# export PKR_VAR_esx_remote_password=$(pass esx_remote_password)
#----------------------------------------------------------------------------------

vm_name                      = "oraclelinux-tkg"
vm_guest_os_type             = "oracleLinux7_64Guest"
vm_guest_version             = "19"
# vm_access_username         = # Reading PKR_VAR_vm_access_username environment variable
# vm_access_password         = # Reading PKR_VAR_vm_access_password environment variable
vm_ssh_timeout               = "30m"
cpu_count                    = "4"
ram_gb                       = "16"
vm_disk_size                 = "100000"

vm_iso_url                   = "iso/OracleLinux-R7-U9-Server-x86_64-dvd.iso"
# vm_iso_url                 = "https://yum.oracle.com/ISOS/OracleLinux/OL7/u9/x86_64/OracleLinux-R7-U9-Server-x86_64-dvd.iso"
vm_iso_checksum              = "sha256:28d2928ded40baddcd11884b9a6a611429df12897784923c346057ec5cdd1012"

boot_key_interval_iso        = "30ms"
boot_wait_iso                = "5s"
boot_keygroup_interval_iso   = "1s"

##----------------------------------------------------------------------------------
# Deployment to VMware vSphere - variables definition
#----------------------------------------------------------------------------------
# vcenter_hostname           = # Reading PKR_VAR_vcenter_username environment variable
# vcenter_username           = # Reading PKR_VAR_vcenter_username environment variable
# vcenter_password           = # Reading PKR_VAR_vcenter_password environment variable
vcenter_cluster              = "west-cluster"
vcenter_datacenter           = "west-dc"
vcenter_datastore            = "nfsdatastore01"
vcenter_folder               = "Templates"
vcenter_port_group           = "lab-mgmt"

#----------------------------------------------------------------------------------
# Deployment to VMware ESX - variables definition
#----------------------------------------------------------------------------------
# esx_remote_hostname        = # Reading PKR_VAR_esx_remote_hostname environment variable
# esx_remote_username        = # Reading PKR_VAR_esx_remote_username environment variable
# esx_remote_password        = # Reading PKR_VAR_esx_remote_password environment variable
esx_remote_type              = "esx5"
esx_remote_datastore         = "datastore1"
esx_port_group               = "PortG_Management"

#----------------------------------------------------------------------------------
# Deployment to VMware Fusion - variables definition
#----------------------------------------------------------------------------------
fusion_app_directory         = "/Applications/VMware Fusion.app"
fusion_output_directory      = "/Users/juliusn/Virtual Machines.localized/oraclelinux.vmwarevm"
