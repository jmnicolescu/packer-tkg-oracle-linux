
## Manage Passwords With GPG and PASS -  the standard unix password manager


#### References:

    PASS - password store
    https://www.passwordstore.org/
    
    PASS - password store - man page
    https://git.zx2c4.com/password-store/about/


### Steps to get PASS configured

#### 1. Create a new GPG key

    \> gpg --gen-key

    You can view your GPG keys by executing the following:

    \> gpg --list-keys

    which should show something like this:

    pub   2038R/91E83BF2 2017-05-13
    uid                  Bob <name@example.com>
    sub   2038R/E3872671 2017-05-13

    Note: Your PUBLIC_KEY_ID is 91E83BF2

#### 2. Initializing the Password Store using the PUBLIC_KEY_ID

    pass init "91E83BF2"

#### 3. Store vCenter secrets by using the pass insert command:

    pass insert provider_vcenter_hostname
    pass insert provider_vcenter_username
    pass insert provider_vcenter_password
    pass insert vm_access_username
    pass insert vm_access_password
    pass insert esx_remote_username
    pass insert esx_remote_password
    
    OR 
    
    echo 'vcenter_hostname' | pass insert provider_vcenter_hostname -e
    echo 'vcenter_username' | pass insert provider_vcenter_username -e
    echo 'vcenter_password' | pass insert provider_vcenter_password -e


#### 4. Set your environment variables - Read secrets from pass and set them as environment variables

    export PKR_VAR_vcenter_hostname=$(pass provider_vcenter_hostname)
    export PKR_VAR_vcenter_username=$(pass provider_vcenter_username)
    export PKR_VAR_vcenter_password=$(pass provider_vcenter_password)
    export PKR_VAR_vm_access_username=$(pass vm_access_username)
    export PKR_VAR_vm_access_password=$(pass vm_access_password)
    export PKR_VAR_esx_remote_hostname=$(pass esx_remote_hostname)
    export PKR_VAR_esx_remote_username=$(pass esx_remote_username)
    export PKR_VAR_esx_remote_password=$(pass esx_remote_password)