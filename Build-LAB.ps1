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

