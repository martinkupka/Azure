# Get Azure VM locations
Get-AzureRmResourceProvider -ProviderNamespace Microsoft.Compute | Select-Object -expand resourcetypes | Where-Object resourcetypename -eq "virtualmachines" | Select-Object -expand locations

# get size of VM per location
Get-AzureRmVMSize -Location "France Central"

# Remove Resource Groups by RG name
Get-AzureRmResourceGroup | Where-Object ResourceGroupName -notlike *RG* | Remove-AzureRmResourceGroup -Verbose -AsJob

# Get VN object
Get-AzureRmVirtualNetwork | Where-Object Name -eq $VNName