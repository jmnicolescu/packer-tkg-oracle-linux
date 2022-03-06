#!/bin/sh

#--------------------------------------------------------------------------------------
# Oracle Linux R7 - Install PowerShell, PowerCLI, PowerNSX [ 27-install-powershell.sh ]
# juliusn - Sun Dec  5 08:48:39 EST 2021 - first version
#--------------------------------------------------------------------------------------

echo "#--------------------------------------------------------------"
echo "# Starting 27-install-powershell.sh" 
echo "#--------------------------------------------------------------"

# Install the .NET Core SDK
yum -y install dotnet-sdk-6.0

# Install the ASP.NET Core runtime
yum -y install dotnet-runtime-6.0

# Install the .NET Core runtime
yum -y install dotnet-sdk-6.0

# Register the Microsoft RedHat repository
curl https://packages.microsoft.com/config/rhel/7/prod.repo | sudo tee /etc/yum.repos.d/microsoft.repo

# Install PowerShell
yum install -y powershell

wget https://github.com/PowerShell/PowerShell/releases/download/v7.1.5/powershell-7.1.5-1.rhel.7.x86_64.rpm
rpm -ivh ./powershell-7.1.5-1.rhel.7.x86_64.rpm
rm -f ./powershell-7.1.5-1.rhel.7.x86_64.rpm

cat << EOF > /root/configure_powercli.ps1
Set-PSRepository -Name "PSGallery" -InstallationPolicy "Trusted"
Find-Module "VMware.PowerCLI" | Install-Module -Scope "AllUsers" -AllowClobber
Get-Module "VMware.PowerCLI" -ListAvailable | FT -Autosize
Get-Module "VMware.*" -ListAvailable | FT -Autosize
Update-Module "VMware.PowerCLI"
Import-Module "VMware.PowerCLI"
Set-PowerCLIConfiguration -InvalidCertificateAction "Ignore" -Confirm:\$false 
Set-PowerCLIConfiguration -Scope User -ParticipateInCEIP \$false -Confirm:\$false
EOF

/bin/pwsh /root/configure_powercli.ps1

#--------------------------------------------------------------------------------------
# Install PowerNSX
# To install for all users (requires PowerShell Run as Administrator):
#--------------------------------------------------------------------------------------

cat << EOF > /root/configure_powernsx.ps1
Find-Module "PowerNSX" | Install-Module -Scope "AllUsers" -AllowClobber      
Get-Module "PowerNSX" -ListAvailable | FT -Autosize
Update-Module "PowerNSX"
Import-Module "PowerNSX"
EOF
/bin/pwsh /root/configure_powernsx.ps1

rm -f /root/configure_powercli.ps1 /root/configure_powernsx.ps1

echo "Done 27-install-powershell.sh"