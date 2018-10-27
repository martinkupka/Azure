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

$NSGroupName = "NSGroup1"
$NSGroupRuleName = "NSFrontEndSubnet"
$NSGroupRuleDesc = "Allows RDP connection on port 3389"

$SourcePort = "*"
$DestinationPort = "3389"
$SourceIP = "92.105.180.100"
$DestinationIP = "*"
$Priority = 1000

$VMName = "VM-LAB1"
$VMLocalAdminUser = "LocalAdminUser"
$VMLocalAdminSecurePassword = ConvertTo-SecureString 'Pa$$w0rd' -AsPlainText -Force
$VMSize = "Standard_D2s_v3"

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

# Set up Security Group on Subnet and allow RDP on 3389
New-AzureRmNetworkSecurityRuleConfig `
    -Name $NSGroupRuleName `
    -Description $NSGroupRuleDesc `
    -Protocol * `
    -SourcePortRange $SourcePort `
    -DestinationPortRange $DestinationPort `
    -SourceAddressPrefix $SourceIP `
    -DestinationAddressPrefix $DestinationIP `
    -Access Allow `
    -Direction Inbound `
    -priority $Priority `
    -OutVariable SecurityRule

New-AzureRmNetworkSecurityGroup `
    -Name $NSGroupName `
    -ResourceGroupName $ResourceGroupName `
    -Location $ResourceGroupLocation `
    -SecurityRules $SecurityRule `
    -OutVariable SecurityGroup

# Create Virtual Network
$DefaultSubnet = New-AzureRmVirtualNetworkSubnetConfig `
    -Name $VNSubnetName `
    -AddressPrefix $VNSubnetAddressPrefix `
    -NetworkSecurityGroup $SecurityGroup `
    -Verbose

New-AzureRmVirtualNetwork `
    -Name $VNName `
    -ResourceGroupName $ResourceGroupName `
    -Location $ResourceGroupLocation `
    -Subnet $DefaultSubnet `
    -AddressPrefix $VNAddressPrefix `
    -OutVariable VirtualNetwork `
    -Verbose

New-AzureRmPublicIpAddress `
    -Name $IPName `
    -ResourceGroupName $ResourceGroupName `
    -Location $ResourceGroupLocation `
    -AllocationMethod Dynamic `
    -OutVariable PublicIP

$virtualsubnet = Get-AzureRmVirtualNetworkSubnetConfig -VirtualNetwork $virtualnetwork

New-AzureRmNetworkInterface `
    -Name $NICName `
    -ResourceGroupName $ResourceGroupName `
    -Location $ResourceGroupLocation `
    -Subnet $VirtualSubnet `
    -PublicIpAddress $PublicIP

# Create VM
$Credential = New-Object System.Management.Automation.PSCredential ($VMLocalAdminUser, $VMLocalAdminSecurePassword)
$NIC = Get-AzureRmNetworkInterface -Name $NICName -ResourceGroupName $ResourceGroupName

$VirtualMachine = New-AzureRmVMConfig `
    -VMName $VMName `
    -VMSize $VMSize

$VirtualMachine = Set-AzureRmVMOperatingSystem `
    -VM $VirtualMachine `
    -Windows `
    -ComputerName $VMName `
    -Credential $Credential `
    -ProvisionVMAgent `
    -EnableAutoUpdate

$VirtualMachine = Add-AzureRmVMNetworkInterface `
    -VM $VirtualMachine `
    -Id $NIC.Id

$VirtualMachine = Set-AzureRmVMSourceImage `
    -VM $VirtualMachine `
    -PublisherName 'MicrosoftWindowsServer' `
    -Offer 'WindowsServer' `
    -Skus  "2016-Datacenter" `
    -Version latest

New-AzureRmVm `
    -ResourceGroupName $ResourceGroupName `
    -Location $ResourceGroupLocation `
    -VM $VirtualMachine