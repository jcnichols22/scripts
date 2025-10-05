# Check for elevated (admin) privileges
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    # Relaunch script with administrator privileges
    Write-Host "Script is not running as administrator. Attempting to restart with elevated privileges..."
    $newProcess = Start-Process -FilePath "powershell.exe" -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

# Now running as administrator — continue with update tasks

# Update Windows
Set-ExecutionPolicy Unrestricted -Force
Install-Module -Name PSWindowsUpdate -Force
Import-Module PSWindowsUpdate
Install-WindowsUpdate -MicrosoftUpdate -AcceptAll -AutoReboot

# Update all applications via winget
winget upgrade --all --silent

# Update all PowerShell modules
Get-InstalledModule | Update-Module
