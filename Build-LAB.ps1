[CmdletBinding()]
Param()

$ResourceGroupName = "RGTestLab"
$ResourceGroupLocation = "France Central"

$StorageAccountName = "samartinkupkatestlab"
$StorageKind = "StorageV2"
$StoragePerfRep = "Standard_LRS"

$VNName = "vnmartinkupkatestlab"
$VNAddressPrefix = "10.0.0.0/16"
$VNSubnetName = "FrontEndSubnet"
$VNSubnetAddressPrefix = "10.0.1.0/24"

$IPName = "publicIP1"

$NICName = "NIC1"
$IPConfigName = "NIC1_PublicIPConfig1"

# Check if AzureRM module is installed and present
if (!(Get-Module -Name *AzureRM*)) {

    # Install the module if it isn't found within available modules
    if (!(Get-Module -Name *AzureRM* -ListAvailable)) {
        Write-Host "Installing AzureRM module" -ForegroundColor Green
        Install-Module -Name AzureRM -AllowClobber -Force
    }

    # Import the module
    Write-Host "Importing AzureRM module" -ForegroundColor Green
    Import-Module -Name AzureRM
}

# Connect and sign in to AzureRM
Write-Host "Connecting to AzureRM" -ForegroundColor Green
Connect-AzureRmAccount

# Create Resource Group
New-AzureRmResourceGroup `
    -Name $ResourceGroupName `
    -Location $ResourceGroupLocation `
    -Verbose

# Create Storage Account
New-AzureRmStorageAccount `
    -ResourceGroupName $ResourceGroupName `
    -Name $StorageAccountName `
    -Location $ResourceGroupLocation `
    -Kind $StorageKind `
    -SkuName $StoragePerfRep `
    -Verbose

# Create Virtual Network
$DefaultSubnet = New-AzureRmVirtualNetworkSubnetConfig `
-Name $VNSubnetName `
-AddressPrefix $VNSubnetAddressPrefix `
-Verbose

New-AzureRmVirtualNetwork `
-Name $VNName `
-ResourceGroupName $ResourceGroupName `
-Location $ResourceGroupLocation `
-Subnet $DefaultSubnet `
-AddressPrefix $VNAddressPrefix `
-OutVariable VirtualNetwork `
-Verbose

$PublicIP = New-AzureRmPublicIpAddress `
-Name $IPName `
-ResourceGroupName $ResourceGroupName `
-Location $ResourceGroupLocation `
-AllocationMethod Dynamic `

$virtualsubnet = Get-AzureRmVirtualNetworkSubnetConfig -VirtualNetwork $virtualnetwork

New-AzureRmNetworkInterface `
-Name $NICName `
-ResourceGroupName $ResourceGroupName `
-Location $ResourceGroupLocation `
-Subnet $VirtualSubnet

# Create VM