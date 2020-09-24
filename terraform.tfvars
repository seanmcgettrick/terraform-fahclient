# Prefix for Azure resource naming.  Default is 'my-fah'
#resourcePrefix = ""

# Azure Region to deploy resources. Default is 'eastus'
#location = ""

# DNS name must be unique within location (defined above) in Azure
dnsName = ""

# User will be used for both SSH and FAH webclient access.  Password for webclient only, SSH uses key
adminUser = ""
adminPassword = ""

# Uncomment and set these if you wish to get credit for your work.
# You do not need to set a team, but if you do I highly suggest team 258829
# Generate a passkey here: https://apps.foldingathome.org/getpasskey You'll want the extra credit it provides, trust me
#fahUser = ""
#fahTeam = ""
#fahPasskey = ""

# VM Size, default is Standard_NV6 (1 Tesla M60 GPU).  Set here to override
# D (no GPU)  : Standard_D1_v2, Standard_D2_v2, Standard_D3_v2, Standard_D4_v2, Standard_D5_v2
# N (GPU)     : Standard_NV6, Standard_NV12, Standard_NV24, 
#               Standard_NV4as_v4, Standard_NV8as_v4, Standard_NV16as_v4, Standard_NV32as_v4
# FOR SPOT VM : Standard_DS1_v2, Standard_DS2s_v3, Standard_DS2_v2, Standard_D4s_v3, Standard_DS3_v2, Standard_D8s_v3
#vmSize = "" 

# Uncomment this if you want to use a Spot VM (https://docs.microsoft.com/en-us/azure/virtual-machines/spot-vms)
# If using a Spot VM, make sure to use one of the supported VM sizes listed above
#spotVm = false

# If using a Spot VM and want to set a max price, uncomment and set it below.  Default is '-1' which means no price cap
#spotVmMaxPrice = ""