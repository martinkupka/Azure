# Get Azure VM locations
Get-AzureRmResourceProvider -ProviderNamespace Microsoft.Compute | Select-Object -expand resourcetypes | Where-Object resourcetypename -eq "virtualmachines" | Select-Object -expand locations

# get size of VM per location
Get-AzureRmVMSize -Location "France Central"

# Remove Resource Groups by RG name
Get-AzureRmResourceGroup | Where-Object ResourceGroupName -notlike *RG* | Remove-AzureRmResourceGroup -Verbose -AsJob

# Get VN object
Get-AzureRmVirtualNetwork | Where-Object Name -eq $VNName

# Changing existing security rule example
Get-AzureRmNetworkSecurityGroup `
    -Name $NSGroupName `
    -ResourceGroupName $ResourceGroupName `
| Set-AzureRmNetworkSecurityRuleConfig `
    -Name $NSGroupRuleName `
    -SourceAddressPrefix "92.105.180.100" `
    -Protocol * `
    -Access Allow `
    -Direction Inbound `
    -SourcePortRange * `
    -DestinationPortRange "3389" `
    -DestinationAddressPrefix * `
    -Priority 1000 `
| Set-AzureRmNetworkSecurityGroup

###################################################################################
# Get Virtual Network from Azure
$VirtualNetwork = Get-AzureRmVirtualNetwork | Where-Object Name -eq $VNName

# Modify the subnet
Set-AzureRmVirtualNetworkSubnetConfig `
    -Name $VNSubnetName `
    -AddressPrefix $VNSubnetAddressPrefix `
    -NetworkSecurityGroup $SecurityGroup `
    -VirtualNetwork $VirtualNetwork

# Commit the change
$virtualnetwork | Set-AzureRmVirtualNetwork
#################################################################################

# https://docs.microsoft.com/en-us/azure/virtual-network/virtual-network-multiple-ip-addresses-powershell

#################################################################################
# Setting Public IP on already existing NIC
$NIC = Get-AzureRmNetworkInterface -Name $NICName -ResourceGroupName $ResourceGroupName

# Grab public IP from Azure
$PublicIP = Get-AzureRmPublicIpAddress

# Assign to NIC
$nic.IpConfigurations[0].PublicIpAddress = $publicip

# Commit
$nic | Set-AzureRmNetworkInterface
#################################################################################