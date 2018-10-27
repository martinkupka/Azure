# Check if AzureRM module is installed and present
if (!(Get-Module -Name *AzureRM*)) {

    # Install the module if it isn't found within available modules
    if (!(Get-Module -Name *AzureRM* -ListAvailable)) {
        Install-Module -Name AzureRM -AllowClobber -Force
    }

    # Import the module
    Import-Module -Name AzureRM
}

# Connect and sign in to AzureRM
Connect-AzureRmAccount

